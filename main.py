import os
import time
from flask import Flask, jsonify
import psycopg2
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = Flask(__name__)

# Basit cache (Key Vault’a her requestte gitmemek için)
_cached = {"ts": 0, "data": None}
CACHE_SECONDS = 300  # 5 dk


def _kv_client() -> SecretClient:
    kv_url = os.environ["KEYVAULT_URL"]  # örn: https://kv-final.vault.azure.net/
    cred = DefaultAzureCredential()
    return SecretClient(vault_url=kv_url, credential=cred)


def _get_secret(client: SecretClient, name: str) -> str:
    return client.get_secret(name).value


def get_db_config() -> dict:
    now = int(time.time())
    if _cached["data"] and (now - _cached["ts"] < CACHE_SECONDS):
        return _cached["data"]

    client = _kv_client()

    # Secret isimleri (env’de override edilebilir)
    host_secret = os.getenv("DB_HOST_SECRET", "DbHost")
    user_secret = os.getenv("DB_USER_SECRET", "DbUser")
    pass_secret = os.getenv("DB_PASSWORD_SECRET", "DbPassword")
    name_secret = os.getenv("DB_NAME_SECRET", "DbName")

    cfg = {
        "host": _get_secret(client, host_secret),
        "user": _get_secret(client, user_secret),
        "password": _get_secret(client, pass_secret),
        "dbname": _get_secret(client, name_secret),
        "port": int(os.getenv("DB_PORT", "5432")),
    }

    _cached["ts"] = now
    _cached["data"] = cfg
    return cfg


def db_ping() -> dict:
    cfg = get_db_config()
    conn = psycopg2.connect(
        host=cfg["host"],
        user=cfg["user"],
        password=cfg["password"],
        dbname=cfg["dbname"],
        port=cfg["port"],
        connect_timeout=5,
        sslmode="disable",  # VM üzerindeki postgres için genelde disable
    )
    cur = conn.cursor()
    cur.execute("SELECT 1;")
    row = cur.fetchone()
    cur.close()
    conn.close()
    return {"ok": True, "select_1": row[0], "db_host": cfg["host"]}


@app.get("/")
def root():
    return jsonify({"service": "final-project-api", "status": "running"})


@app.get("/health")
def health():
    return jsonify({"ok": True})


@app.get("/db")
def db():
    try:
        return jsonify(db_ping())
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


if __name__ == "__main__":
    # Azure App Service container, uygulamanın PORT env değişkeninden okumasını bekler.
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
