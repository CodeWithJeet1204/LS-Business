const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sharp = require('sharp');

admin.initializeApp();

exports.checkImageBlur = functions.region('asia-southeast1').https.onRequest(async (req, res) => {
    const imageBuffer = req.body.image;

    try {
        const { data, info } = await sharp(imageBuffer)
            .grayscale()
            .raw()
            .toBuffer({ resolveWithObject: true });

        const width = info.width;
        const height = info.height;
        let laplacianSum = 0;

        for (let y = 1; y < height - 1; y++) {
            for (let x = 1; x < width - 1; x++) {
                const pixel = data[y * width + x];
                const laplacianValue = (
                    data[(y - 1) * width + (x - 1)] +
                    data[(y - 1) * width + x] * -4 +
                    data[(y - 1) * width + (x + 1)] +
                    data[y * width + (x - 1)] +
                    data[y * width + (x + 1)] +
                    data[(y + 1) * width + (x - 1)] +
                    data[(y + 1) * width + x] +
                    data[(y + 1) * width + (x + 1)]
                );
                laplacianSum += laplacianValue;
            }
        }

        const variance = laplacianSum / (width * height);
        const isBlurred = variance < 50;

        res.json({ isBlurred });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error processing image');
    }
});

exports.deleteUserAccount = functions.region('asia-southeast1').https.onRequest(async (req, res) => {
    try {
        const { userId } = req.body;
        await admin.auth().deleteUser(userId);
        res.status(200).send({ success: true, message: 'User account deleted successfully' });
    } catch (error) {
        console.error("Error deleting user:", error);
        res.status(500).send({ success: false, message: error.message });
    }
});
