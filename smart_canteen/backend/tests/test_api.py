import sqlite3
import tempfile
import unittest
from contextlib import closing
from pathlib import Path

from backend import app as backend_app


PROJECT_DIR = Path(__file__).resolve().parents[2]


class ApiTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "test.db"
        with closing(sqlite3.connect(self.db_path)) as connection:
            schema = (PROJECT_DIR / "database" / "schema.sql").read_text(
                encoding="utf-8"
            )
            connection.executescript(schema)
            connection.execute(
                """
                INSERT INTO users (username, email, password_hash, role, phone)
                VALUES ('admin', 'admin@canteen.edu', 'admin123', 'admin', '9876543210')
                """
            )
            cursor = connection.execute(
                """
                INSERT INTO shops (shop_no, name, contact_no, location, admin_id)
                VALUES ('TEST-01', 'Test Canteen', '9876543210', 'Test Campus', 1)
                """
            )
            self.shop_id = cursor.lastrowid
            cursor = connection.execute(
                """
                INSERT INTO menu_items (shop_id, name, category, price, quantity)
                VALUES (?, 'Test Meal', 'Meals', 25.50, 5)
                """,
                (self.shop_id,),
            )
            self.menu_item_id = cursor.lastrowid
            connection.execute(
                """
                INSERT INTO shops (shop_no, name, contact_no, location, admin_id)
                VALUES ('TEST-02', 'Other Canteen', '5559999', 'Other Campus', 99)
                """
            )
            connection.commit()

        self.original_db_path = backend_app.DB_PATH
        backend_app.DB_PATH = str(self.db_path)
        backend_app.app.config["TESTING"] = True
        self.client = backend_app.app.test_client()

    def tearDown(self):
        backend_app.DB_PATH = self.original_db_path
        self.temp_dir.cleanup()

    def test_health_and_shop_menu_reads(self):
        self.assertEqual(self.client.get("/api/health").status_code, 200)
        shops = self.client.get("/api/shops").get_json()["shops"]
        self.assertEqual(shops[0]["id"], self.shop_id)
        menu = self.client.get(
            f"/api/shops/{self.shop_id}/menu"
        ).get_json()["dishes"]
        self.assertEqual(menu[0]["id"], self.menu_item_id)

    def test_user_registration_and_login(self):
        registration = self.client.post(
            "/api/auth/register",
            json={
                "username": "test-student",
                "email": "student@example.invalid",
                "password": "test-password",
            },
        )
        self.assertEqual(registration.status_code, 201)
        login = self.client.post(
            "/api/auth/login",
            json={
                "username": "test-student",
                "password": "test-password",
                "role": "user",
            },
        )
        self.assertEqual(login.status_code, 200)

    def test_admin_login_and_role_validation(self):
        # Successful admin login with username
        resp = self.client.post(
            "/api/auth/login",
            json={"username": "admin", "password": "admin123", "role": "admin"},
        )
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(resp.get_json()["success"])
        self.assertEqual(resp.get_json()["user"]["role"], "admin")
        self.assertIsNotNone(resp.get_json().get("shop"))
        self.assertEqual(resp.get_json()["shop"]["id"], self.shop_id)

        # Successful admin login with email and case-insensitivity
        resp_email = self.client.post(
            "/api/auth/login",
            json={"username": "ADMIN@CANTEEN.EDU", "password": "admin123", "role": "Admin"},
        )
        self.assertEqual(resp_email.status_code, 200)

        # Admin login role mismatch
        mismatch = self.client.post(
            "/api/auth/login",
            json={"username": "admin", "password": "admin123", "role": "user"},
        )
        self.assertEqual(mismatch.status_code, 401)

        # Invalid password
        bad_pw = self.client.post(
            "/api/auth/login",
            json={"username": "admin", "password": "wrongpassword", "role": "admin"},
        )
        self.assertEqual(bad_pw.status_code, 401)

    def test_get_shops_filtered_by_admin(self):
        # All shops without filter
        all_shops = self.client.get("/api/shops").get_json()["shops"]
        self.assertEqual(len(all_shops), 2)

        # Filtered by admin_id = 1
        admin_shops = self.client.get("/api/shops?admin_id=1").get_json()["shops"]
        self.assertEqual(len(admin_shops), 1)
        self.assertEqual(admin_shops[0]["id"], self.shop_id)

    def test_cors_preflight_and_headers(self):
        resp = self.client.options(
            "/api/auth/login",
            headers={
                "Origin": "http://localhost:54321",
                "Access-Control-Request-Method": "POST",
                "Access-Control-Request-Headers": "content-type",
            },
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("Access-Control-Allow-Origin"), "http://localhost:54321")
        self.assertIn("content-type", resp.headers.get("Access-Control-Allow-Headers", "").lower())

    def test_shop_update(self):
        response = self.client.put(
            f"/api/shops/{self.shop_id}",
            json={"name": "Updated Canteen", "location": "New Campus"},
        )
        self.assertEqual(response.status_code, 200)
        shop = self.client.get(f"/api/shops/{self.shop_id}").get_json()["shop"]
        self.assertEqual(shop["name"], "Updated Canteen")
        self.assertEqual(shop["location"], "New Campus")

    def test_shop_and_weekly_menu_setup(self):
        shop_response = self.client.post(
            "/api/shops",
            json={
                "shop_no": "NEW-01",
                "name": "New Test Shop",
                "owner_name": "Test Owner",
                "contact_no": "5550101",
                "location_type": "Food Court",
                "location": "North Campus",
            },
        )
        self.assertEqual(shop_response.status_code, 201)
        new_shop_id = shop_response.get_json()["shop_id"]
        menu_response = self.client.post(
            f"/api/shops/{new_shop_id}/menu",
            json={
                "name": "Friday Special",
                "category": "Meals",
                "price": 42,
                "quantity": 8,
                "day_of_week": "Friday",
            },
        )
        self.assertEqual(menu_response.status_code, 201)
        friday_menu = self.client.get(
            f"/api/shops/{new_shop_id}/menu?day=Friday"
        ).get_json()["dishes"]
        monday_menu = self.client.get(
            f"/api/shops/{new_shop_id}/menu?day=Monday"
        ).get_json()["dishes"]
        self.assertEqual(len(friday_menu), 1)
        self.assertEqual(monday_menu, [])
        deleted = self.client.delete(
            f"/api/menu/{menu_response.get_json()['dish_id']}"
        )
        self.assertEqual(deleted.status_code, 200)

    def test_order_token_inventory_and_status_flow(self):
        response = self.client.post(
            "/api/orders",
            json={
                "shop_id": self.shop_id,
                "customer_name": "Test Student",
                "payment_method": "UPI",
                "items": [{"menu_item_id": self.menu_item_id, "quantity": 2}],
            },
        )
        self.assertEqual(response.status_code, 201)
        order = response.get_json()
        self.assertTrue(order["token"].startswith("#TK-"))
        self.assertEqual(order["payment_status"], "pending")

        with closing(sqlite3.connect(self.db_path)) as connection:
            inventory = connection.execute(
                "SELECT quantity FROM menu_items WHERE id = ?",
                (self.menu_item_id,),
            ).fetchone()[0]
        self.assertEqual(inventory, 3)

        update = self.client.patch(
            f"/api/orders/{order['order_id']}/status",
            json={"status": "preparing"},
        )
        self.assertEqual(update.status_code, 200)
        incoming = self.client.get(
            f"/api/shops/{self.shop_id}/orders"
        ).get_json()["orders"]
        self.assertEqual(incoming[0]["status"], "preparing")

    def test_order_rejects_quantity_above_stock(self):
        response = self.client.post(
            "/api/orders",
            json={
                "shop_id": self.shop_id,
                "customer_name": "Test Student",
                "items": [{"menu_item_id": self.menu_item_id, "quantity": 6}],
            },
        )
        self.assertEqual(response.status_code, 409)
        with closing(sqlite3.connect(self.db_path)) as connection:
            order_count = connection.execute(
                "SELECT COUNT(*) FROM orders"
            ).fetchone()[0]
        self.assertEqual(order_count, 0)


if __name__ == "__main__":
    unittest.main()
