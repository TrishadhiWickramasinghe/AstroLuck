import sqlite3

conn = sqlite3.connect('astroluck.db')
cursor = conn.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
tables = cursor.fetchall()

print("\n" + "="*50)
print("🗄️  AstroLuck Database - Verification")
print("="*50)
print(f"\n✓ Database file: astroluck.db")
print(f"✓ Database type: SQLite\n")
print("Tables created:")
for table in tables:
    cursor.execute(f"PRAGMA table_info({table[0]})")
    columns = cursor.fetchall()
    print(f"\n  📋 {table[0]}")
    print(f"     Columns: {len(columns)}")
    for col in columns:
        print(f"       - {col[1]} ({col[2]})")

conn.close()
print("\n" + "="*50)
print("✓ Database setup complete!")
print("="*50 + "\n")
