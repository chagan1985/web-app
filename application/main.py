##########
#
# Christopher Hagan
#
##########

import os

from app import app

DEFAULT_FLASK_PORT = 5000

def main():
    port = int(os.environ.get("PORT", DEFAULT_FLASK_PORT))
    app.run(host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
