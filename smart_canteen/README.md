# Quick Queue / Smart Canteen

Flutter client and Flask API backed by SQLite. PostgreSQL is not configured or
used by the current backend.

## Windows setup

Run these commands in PowerShell from this directory:

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt
```

The existing database is `database\canteen.db`. It already contains tables and
data; do not initialize it again unless setting up a separate, fresh database.
For a fresh local database only, run:

```powershell
python database\init_db.py
```

The initializer creates the SQLite tables and inserts the bundled sample
records. It does not configure PostgreSQL.

## Run the app

Start the backend in one PowerShell window:

```powershell
.\.venv\Scripts\Activate.ps1
python -m flask --app backend.app run --host 127.0.0.1 --port 5000
```

In another PowerShell window, start the Flutter web client:

```powershell
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:5000/api
```

For the Android emulator, use
`--dart-define=API_BASE_URL=http://10.0.2.2:5000/api`; for the Windows desktop
client, use `http://127.0.0.1:5000/api`. A physical phone needs the computer's
LAN address and the backend bound to `0.0.0.0` (for example, replace the run
command's host with `0.0.0.0`), plus an allowed firewall rule.

## Checks

```powershell
flutter analyze
flutter test
python -m unittest discover -s backend\tests
```

The app uses simulated checkout selection only; there is no payment provider.
Orders and tokens are created by the backend, with payment left pending.
