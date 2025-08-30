from flask import Flask, render_template, request, redirect, url_for
import sqlite3

app = Flask(__name__)
DB_NAME = "tasks.db"

def init_db():
    with sqlite3.connect(DB_NAME) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT
            )
        """)
    print("Database initialized")

@app.route("/")
def index():
    with sqlite3.connect(DB_NAME) as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM tasks")
        tasks = cur.fetchall()
    return render_template("index.html", tasks=tasks)

@app.route("/add", methods=["POST"])
def add():
    title = request.form["title"]
    description = request.form["description"]
    with sqlite3.connect(DB_NAME) as conn:
        conn.execute("INSERT INTO tasks (title, description) VALUES (?, ?)", (title, description))
    return redirect(url_for("index"))

@app.route("/delete/<int:task_id>")
def delete(task_id):
    with sqlite3.connect(DB_NAME) as conn:
        conn.execute("DELETE FROM tasks WHERE id=?", (task_id,))
    return redirect(url_for("index"))

@app.route("/update/<int:task_id>", methods=["POST"])
def update(task_id):
    title = request.form["title"]
    description = request.form["description"]
    with sqlite3.connect(DB_NAME) as conn:
        conn.execute("UPDATE tasks SET title=?, description=? WHERE id=?", (title, description, task_id))
    return redirect(url_for("index"))

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)
