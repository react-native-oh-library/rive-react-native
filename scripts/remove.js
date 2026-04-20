const fs = require('fs');

try {
    fs.unlinkSync('./harmony/rive/rive_ohos.har');
} catch (err) {
    console.error('del error：', err);
}
