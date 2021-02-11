import argparse
import io
import sys
import time

import picamera
import tensorflow as tf
from PIL import Image

from detect_picamera import set_input_tensor, get_output_tensor, detect_objects

CAMERA_WIDTH = 640
CAMERA_HEIGHT = 480


def parse_args():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        '--model',
        help='File path of .tflite file.',
        required=True
    )
    parser.add_argument(
        '--threshold',
        help='Score threshold for detected objects.',
        required=False,
        type=float,
        default=0.4
    )
    parser.add_argument(
        '--timeout',
        help='Timeout seconds.',
        required=False,
        type=int,
        default=5400
    )
    parser.add_argument(
        '--inverse',
        help='Inverse detect result.',
        action='store_true'
    )
    return parser.parse_args()


def main():
    start_time = time.monotonic()
    args = parse_args()

    interpreter = tf.lite.Interpreter(args.model)
    interpreter.allocate_tensors()
    _, input_height, input_width, _ = interpreter.get_input_details()[0]['shape']

    with picamera.PiCamera(resolution=(CAMERA_WIDTH, CAMERA_HEIGHT), framerate=30) as camera:
        camera.start_preview()
        try:
            stream = io.BytesIO()
            for i, _ in enumerate(camera.capture_continuous(stream, format='jpeg', use_video_port=True)):
                stream.seek(0)
                image = Image.open(stream) \
                             .convert('RGB') \
                             .resize((input_width, input_height), Image.ANTIALIAS)
                results = detect_objects(interpreter, image, args.threshold)

                for result in results:
                    if args.inverse ^ (result['class_id'] == 0):
                        sys.exit(0)

                if time.monotonic() - start_time > args.timeout:
                    sys.exit(1)

                stream.seek(0)
                stream.truncate()
        finally:
            camera.stop_preview()


if __name__ == '__main__':
    main()