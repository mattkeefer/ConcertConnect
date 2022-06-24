from flask import Flask, render_template, redirect, url_for, request, g
import pymysql
from credentials import db_username, db_password

app = Flask(__name__)

db = pymysql.connect(host='localhost', user=db_username, password=db_password, db='concertconnect', charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)
cur = db.cursor()


@app.route('/')
def entry():
        return render_template('entry.html')

@app.route('/<username>')
def index(username):
        return render_template('index.html', username=username)

@app.route('/register', methods=['GET', 'POST'])
def register():
        error = None
        if request.method == 'POST':
                usr = request.form['username']
                sql = f'SELECT numUsersWithUsername("{usr}") AS num_users'
                cur.execute(sql)
                result = cur.fetchall()
                num = result[0]['num_users']
                if num > 0:
                        error = 'Username taken. Please try again.'
                else:
                        cur.callproc('createUser', [usr])
                        db.commit()
                        return redirect(url_for('login'))
        return render_template('register.html', error=error)

@app.route('/login', methods=['GET', 'POST'])
def login():
        error = None
        if request.method == 'POST':
                usr = request.form['username']
                sql = f'SELECT numUsersWithUsername("{usr}") AS num_users'
                cur.execute(sql)
                result = cur.fetchall()
                num = result[0]['num_users']
                if num < 1:
                        error = 'Invalid Credentials. Please try again.'
                else:
                        return redirect(f'/{usr}')
        return render_template('login.html', error=error)

@app.route('/<username>/concert')
def concerts(username):
        sql = 'SELECT * FROM concert AS concerts ORDER BY concertDate ASC'
        cur.execute(sql)
        concerts = cur.fetchall()
        sql = f'SELECT * FROM location AS locations'
        cur.execute(sql)
        locations = cur.fetchall()
        return render_template('concerts.html', concerts=concerts, locations=locations, username=username)


@app.route('/<username>/concert/<int:concert_id>', methods=['GET', 'POST'])
def concert(username, concert_id):
        sql = f'SELECT * FROM concert WHERE concertId = {concert_id}'
        cur.execute(sql)
        result = cur.fetchall()
        concert = result[0]
        venId = concert['location']
        sql = f'SELECT * FROM location WHERE venueId = {venId}'
        cur.execute(sql)
        result = cur.fetchall()
        location = result[0]
        cur.callproc('artistsPerforming', [concert_id])
        artists = cur.fetchall()
        sql = f'SELECT isAttending("{username}", {concert_id}) AS attending'
        cur.execute(sql)
        result = cur.fetchall()
        isAttending = result[0]['attending']
        cur.callproc('cliquesWithUserNotShared', [f'{username}', concert_id])
        cliques = cur.fetchall()
        print(cliques)

        error = None
        if request.method == 'POST':
                clique = request.form['clique_name']
                print(clique)
                try:
                        cur.callproc('shareConcert', [concert_id, clique])
                        db.commit()
                        return redirect(f'/{username}/clique/{clique}')
                except pymysql.Error:
                        error = 'An error occurred.'
                        db.rollback()

        return render_template('concert.html', concert=concert, location=location, artists=artists, isAttending=isAttending, cliques=cliques, username=username, error=error)


@app.route('/<username>/concert/<int:concert_id>/attend')
def attend(username, concert_id):
        try:
                cur.callproc('attending', [f'{username}', concert_id])
                db.commit()
        except pymysql.Error:
                db.rollback()
        return redirect(f'/{username}/concert')

@app.route('/<username>/concert/<int:concert_id>/not-attend')
def not_attend(username, concert_id):
        try:
                cur.callproc('notAttending', [f'{username}', concert_id])
                db.commit()
        except pymysql.Error:
                db.rollback()
        return redirect(f'/{username}/concert')

@app.route('/<username>/clique', methods=['GET', 'POST'])
def cliques(username):
        cur.callproc('cliquesWithUser', [f'{username}'])
        member = cur.fetchall()
        cur.callproc('cliqueMembershipWithoutUser', [f'{username}'])
        cliques = cur.fetchall()
        error = None
        if request.method == 'POST':
                name = request.form['name']
                genre = request.form['genre']
                try:
                        cur.callproc('createClique', [f'{username}', f'{name}', f'{genre}'])
                        db.commit()
                        return redirect(f'/{username}/clique')
                except pymysql.Error:
                        error = 'Invalid clique name or genre.'
                        db.rollback()
        return render_template('cliques.html', member=member, cliques=cliques, username=username, error=error)

@app.route('/<username>/clique/<int:clique_id>')
def clique(username, clique_id):
        sql = f'SELECT * FROM clique WHERE cliqueId = {clique_id}'
        cur.execute(sql)
        result = cur.fetchall()
        clique = result[0]
        cur.callproc('usersInClique', [clique_id])
        members = cur.fetchall()
        cur.callproc('concertsSharedWithClique', [clique_id])
        shared = cur.fetchall()
        return render_template('clique.html', clique=clique, members=members, shared=shared, username=username)

@app.route('/<username>/clique/<int:clique_id>/join')
def join(username, clique_id):
        try:
                cur.callproc('joinClique', [f'{username}', clique_id])
                db.commit()
        except pymysql.Error:
                db.rollback()
        return redirect(f'/{username}/clique')

@app.route('/<username>/clique/<int:clique_id>/leave')
def leave(username, clique_id):
        try:
                cur.callproc('leaveClique', [f'{username}', clique_id])
                db.commit()
        except pymysql.Error:
                db.rollback()
        return redirect(f'/{username}/clique')

@app.route('/<username>/profile', methods=['GET', 'POST'])
def profile(username):
        sql = f'SELECT * FROM user WHERE username = "{username}"'
        cur.execute(sql)
        user = cur.fetchall()
        cur.callproc('concertsAttending', [f'{username}'])
        attending = cur.fetchall()
        cur.callproc('cliquesWithUser', [f'{username}'])
        member = cur.fetchall()
        error = None
        if request.method == 'POST': 
                name = request.form['name']
                age = request.form['age']
                try:
                        cur.callproc('updateUserInfo', [username, name, age])
                        db.commit()
                        return redirect(f'/{username}/profile')
                except pymysql.Error:
                        error = 'Invalid name or age.'
                        db.rollback()
        return render_template('profile.html', user=user[0], attending=attending, member=member, username=username, error=error)

