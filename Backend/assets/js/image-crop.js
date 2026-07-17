/* Shared image-crop helper (Cropper.js wrapper) used across admin/store upload forms.
   Each page includes cropper.min.js/css + this file, renders one #cropModal,
   and wires each <input type="file"> with onchange="ImageCrop.open(this,'hiddenId')"
   (or .openMulti(...) for multi-file fields), writing the cropped result as a
   base64 data URI into the named hidden input for the PHP side to decode. */

var ImageCrop = (function(){

    var cropperInstance = null;
    var queue = [];
    var queueResults = [];
    var currentMode = null; // 'single' | 'multi'
    var currentHiddenInputId = null;
    var currentAspectRatio = 1;

    function isImage(file){
        return !!(file && file.type && file.type.indexOf('image/') === 0);
    }

    function openModal(dataUrl, aspectRatio){

        var img = document.getElementById('cropperImage');
        img.src = dataUrl;

        document.getElementById('cropModal').classList.add('active');

        if(cropperInstance){
            cropperInstance.destroy();
        }

        cropperInstance = new Cropper(img, {
            aspectRatio: aspectRatio,
            viewMode: 1,
            autoCropArea: 1
        });
    }

    function closeModal(){

        document.getElementById('cropModal').classList.remove('active');

        if(cropperInstance){
            cropperInstance.destroy();
            cropperInstance = null;
        }
    }

    /* Single-image field: crop one file into one hidden input */
    function open(fileInput, hiddenInputId, aspectRatio){

        aspectRatio = aspectRatio || 1;

        if(!fileInput.files || !fileInput.files[0]){
            return;
        }

        if(!isImage(fileInput.files[0])){
            return; // e.g. a video chosen in a mixed image/video field — no crop step for video
        }

        currentMode = 'single';
        currentHiddenInputId = hiddenInputId;
        currentAspectRatio = aspectRatio;

        var reader = new FileReader();

        reader.onload = function(e){
            openModal(e.target.result, aspectRatio);
        };

        reader.readAsDataURL(fileInput.files[0]);
    }

    /* Multi-image field: crop each selected file one after another,
       collecting results into a JSON array written to one hidden input */
    function openMulti(fileInput, hiddenInputId, aspectRatio){

        aspectRatio = aspectRatio || 1;

        if(!fileInput.files || fileInput.files.length === 0){
            return;
        }

        queue = Array.prototype.filter.call(fileInput.files, isImage);
        queueResults = [];
        currentMode = 'multi';
        currentHiddenInputId = hiddenInputId;
        currentAspectRatio = aspectRatio;

        processNextInQueue();
    }

    function processNextInQueue(){

        if(queue.length === 0){
            document.getElementById(currentHiddenInputId).value = JSON.stringify(queueResults);
            return;
        }

        var file = queue.shift();
        var reader = new FileReader();

        reader.onload = function(e){
            openModal(e.target.result, currentAspectRatio);
        };

        reader.readAsDataURL(file);
    }

    function apply(){

        if(!cropperInstance){
            return;
        }

        var canvas = cropperInstance.getCroppedCanvas({ width: 800, height: 800 });
        var dataUrl = canvas.toDataURL('image/jpeg', 0.9);

        if(currentMode === 'multi'){
            queueResults.push(dataUrl);
            closeModal();
            processNextInQueue();
        }else{
            document.getElementById(currentHiddenInputId).value = dataUrl;
            closeModal();
        }
    }

    function skip(){

        if(currentMode === 'multi'){
            closeModal();
            processNextInQueue();
        }else{
            if(currentHiddenInputId){
                document.getElementById(currentHiddenInputId).value = '';
            }
            closeModal();
        }
    }

    return {
        open: open,
        openMulti: openMulti,
        apply: apply,
        skip: skip
    };

})();
