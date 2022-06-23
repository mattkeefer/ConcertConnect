from flask import Flask, render_template, redirect, url_for, request
import pymysql

app = Flask(__name__)

# db = pymysql.connect(host='localhost', user='root', password='Hershey!likes2catnap', db='concertconnect', charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)
# cur = db.cursor()


@app.route('/')
def entry():
        return render_template('entry.html')

@app.route('/home')
def index():
        return render_template('index.html')

# @app.route('/register', methods=['GET', 'POST'])
# def register():
#         error = None
#         if request.method == 'POST':
#                 usr = request.form['username']
#                 sql = f'SELECT numUsersWithUsername("{usr}") AS num_users'
#                 cur.execute(sql)
#                 result = cur.fetchall()
#                 num = result[0]['num_users']
#                 if num > 0:
#                         error = 'Username taken. Please try again.'
#                 else:
#                         cur.callproc('createUser', [usr])
#                         db.commit()
#                         return redirect(url_for('login'))
#         return render_template('register.html', error=error)

# @app.route('/login', methods=['GET', 'POST'])
# def login():
#         error = None
#         if request.method == 'POST':
#                 usr = request.form['username']
#                 sql = f'SELECT numUsersWithUsername("{usr}") AS num_users'
#                 cur.execute(sql)
#                 result = cur.fetchall()
#                 num = result[0]['num_users']
#                 if num < 1:
#                         error = 'Invalid Credentials. Please try again.'
#                 else:
#                         return redirect(url_for('index'))
#         return render_template('login.html', error=error)

# @app.route('/concert')
# def concerts():
#         sql = 'SELECT * FROM concert AS concerts ORDER BY concertDate ASC'
#         cur.execute(sql)
#         result = cur.fetchall()
#         return render_template('concerts.html', concerts=result)

# @app.route('/concert/<int:concert_id>')
# def concert(concert_id):
#         sql = f'SELECT * FROM concert AS concerts WHERE concertId = {concert_id}'
#         cur.execute(sql)
#         result = cur.fetchall()
#         return render_template('concert.html', concert=result[0])

@app.route('/clique')
def cliques():
        return render_template('cliques.html')

@app.route('/clique/<int:clique_id>')
def clique(clique_id):
        return f'<h1>Clique {clique_id}</h1>'

@app.route('/profile/<username>')
def profile(username):
        return render_template('profile.html', username=username)

