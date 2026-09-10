import importlib.util
from pathlib import Path
import unittest
from PIL import Image

spec = importlib.util.spec_from_file_location(
    "background", Path(__file__).parents[1] / "config/quickshell/sample-background.py")
background = importlib.util.module_from_spec(spec)
spec.loader.exec_module(background)


class BackgroundSamplingTests(unittest.TestCase):
    def test_black_and_white(self):
        self.assertEqual(background.sample(Image.new("RGB", (128, 42), "black")), [0, 0])
        self.assertEqual(background.sample(Image.new("RGB", (128, 42), "white")), [1, 1])

    def test_local_contrast_and_partial_cell(self):
        image = Image.new("RGB", (130, 42), "black")
        image.paste("white", (64, 0, 130, 42))
        self.assertEqual(background.sample(image), [0, 1, 1])

    def test_foreground_does_not_feed_back_into_sample(self):
        image = Image.new("RGB", (128, 42), "white")
        image.paste("black", (0, 7, 128, 35))
        self.assertEqual(background.sample(image), [1, 1])

    def test_mid_gray_uses_linear_luminance(self):
        value = background.sample(Image.new("RGB", (64, 42), (128, 128, 128)))[0]
        self.assertAlmostEqual(value, 0.21586, places=4)


if __name__ == "__main__":
    unittest.main()
