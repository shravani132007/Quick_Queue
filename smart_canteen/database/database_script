#!/usr/bin/env python3
"""
Quick Queue / Smart Canteen
Database Initialization & Seeding Script
"""

import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "canteen.db")
SCHEMA_PATH = os.path.join(BASE_DIR, "SQL_schema")


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def init_database():
    print(f"[*] Initializing database at: {DB_PATH}")

    if not os.path.exists(SCHEMA_PATH):
        raise FileNotFoundError(f"Schema file not found at {SCHEMA_PATH}")

    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        schema_sql = f.read()

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.executescript(schema_sql)
        conn.commit()
        print("[+] Database tables and initial seed data created successfully!")

        # Verify
        cursor.execute("SELECT COUNT(*) FROM shops;")
        shops_count = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM menu_items;")
        dishes_count = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM orders;")
        orders_count = cursor.fetchone()[0]

        print(f"[*] Summary:")
        print(f"    - Shops: {shops_count}")
        print(f"    - Menu Dishes: {dishes_count}")
        print(f"    - Initial Orders: {orders_count}")

    except Exception as e:
        conn.rollback()
        print(f"[!] Error initializing database: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    init_database()
