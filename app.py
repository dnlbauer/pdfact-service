from flask import Flask, request, flash, Response
from werkzeug.utils import secure_filename
import logging
from os import path, remove
import tempfile
import subprocess as sp

app = Flask(__name__)


def get_format(req, fallback=("application/json", "json")):
    accept = req.headers.get("accept").lower()
    if accept == "application/json":
        return accept, "json"
    elif accept == "application/xml":
        return accept, "xml"
    elif accept == "text/plain":
        return accept, "txt"
    else:
        return fallback

@app.route('/', methods=["GET"])
def healthcheck():
    return "OK", 200


@app.route('/analyze', methods=["POST"])
def analyze():
    if "file" not in request.files or len(request.files["file"].filename) == 0:
        flash("No file.")
        return

    # save file to tmp folder
    file = request.files["file"]
    file_path = path.join(tempfile.gettempdir(), secure_filename(file.filename))
    app.logger.debug(f"saving file as {file_path}")
    file.save(file_path)

    cmd = ["java", "-jar", "/pdfact.jar", file_path]

    mime, response_format = get_format(request)
    cmd += ["--format", response_format]

    units = request.args.get("units", None)
    if units is not None:
        cmd += ["--units", units]

    roles = request.args.get("roles", None)
    if roles is not None:
        cmd += ["--include-roles", roles]

    app.logger.debug(f"running {' '.join(cmd)}")

    try:
        result = sp.check_output(cmd, stderr=sp.STDOUT)
        return Response(result, mimetype=mime)
    except sp.CalledProcessError as e:
        app.logger.error("Error running pdfact:", e.output.decode())
        return f"Error running pdfact: {e.output.decode()}", 500
    finally:
        remove(file_path)

if __name__ == '__main__':
    app.run()
else:
    # use gunicorns loglevel
    gunicorn_logger = logging.getLogger("gunicorn.error")
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)
    app.logger.warn(gunicorn_logger.level)
