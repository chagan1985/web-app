##########
#
# Christopher Hagan
#
##########

import os

from flask import Flask, request, abort

app = Flask(__name__)


@app.before_request
def require_token():
    expected = os.environ.get("API_TOKEN")
    if not expected:
        abort(500, "API_TOKEN not configured")
    auth = request.headers.get("Authorization", "")
    if auth != f"Bearer {expected}":
        abort(401)


@app.route("/")
def index():
    return "Wooo go Broncos!"
