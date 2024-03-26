from flask import Flask, session, redirect, url_for, render_template, request
from auction import Auction, AuctionService, User, UserService

app = Flask(__name__, template_folder='templates')

info = {
    'address': ''
}

user_service = UserService()
user_service.users = [
    User('0x0sgjndflkvjnsnfkljnsdf', 'Tom'),
    User('0x0ababababababa03495', 'Max')
]


@app.route('/', methods=['GET'])
def index():
    if info.get('address') is None or info.get('address') == '':
        return redirect(url_for('login'))
    return render_template('index.html', address=info.get('address'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # make metamask sign
        info['address'] = request.form['address']
        return redirect(url_for('index'))
    if request.method == 'GET':
        return render_template('login.html')


if __name__ == '__main__':
    app.run(debug=True, port=8080)
