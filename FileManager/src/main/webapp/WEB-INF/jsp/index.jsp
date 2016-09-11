<%--
  Created by IntelliJ IDEA.
  User: park
  Date: 2016-08-11
  Time: 오후 6:26
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<meta http-equiv="Cache-Control" content="no-cache">
<head>
    <title>:: 파일 관리자 ::</title>
    <link rel="stylesheet" type="text/css" href="./css/default.css">
    <script src="./js/jquery/jquery-3.1.0.min.js"></script>
    <script src="./js/utils.js"></script>
    <script type="text/javascript">

        $(document).ready(function() {

            $(document).ajaxStart(function(){
                $('html, body').css("cursor", "wait");
            });

            $(document).ajaxComplete(function(){
                $('html, body').css("cursor", "auto");
            });


            $("#top-toolbar-container").append( $("#toolbar").clone() );

            function getStatusCompleteHandler(data)
            {
                //CURSOR.normal();

                $("table.file-table > tbody > tr").remove();


                if(data.isRoot)
                    $(".btn-parent").css("display" , "none");
                else
                    $(".btn-parent").css("display" , "");



                data.files.sort(function(item1 , item2){return item1.isFile - item2.isFile;}).forEach(function(item){

                    var newRow = $("tr.row-templete").clone().removeClass("row-templete");
                    newRow.data("name" , item.name);
                    newRow.data("isFile" , item.isFile);

                    if(item.isFile === false)
                    {
//                        $("td.col-name", newRow).css("cursor" , "hand");
                        $("td.col-name > img", newRow).attr("src", "./image/folder.png");
                        $("option[value='download']" , newRow).remove();
                    }
                    else
                    {
                        $("td.col-name > img", newRow).attr("src", "./image/file.png");

                        $("td.col-size", newRow).html(formatBytes(item.length));
                        $("td.col-ext", newRow).html(item.extension.toLowerCase());
                    }

                    $("td.col-name > span" , newRow).html(item.name);
                    $("td.col-name", newRow).click(function(event){


                        var data = $(this).parent("tr").data();

                        if(data.isFile === false)
                        {
//                            CURSOR.busy();
                            $.post("./api/child" , {"directory":data.name} , getStatusCompleteHandler);
                        }
                    });






                    $("table.file-table > tbody").append(newRow);
                });

                $(".btn-actions").change(function(event){

                    var name = $(this).parents("tr").data("name");

                    switch( $(this).val() )
                    {
                        case "rename":
                            $("#popup").show();
                            $("#popup").data("cmd" , "rename");
                            $("#popup").data("target" , name);
                            $("#popup-input-text").val(name);
                            break;
                        case "download":
                            $("#form-download > input[name='name']").attr("value" , name);
                            $("#form-download").attr("action" , "./api/download");
                            $("#form-download").submit();

                                //./api/download
                            break;
                    }

                    $(this).val("");
                });

                $("table.file-table > tbody > tr:even").addClass("even-class");

            };




            $(".btn-parent").click(function(event){
                $.post("./api/parent" , getStatusCompleteHandler);
            });

            $(".btn-home").click(function(event){
                $.post("./api/home" , getStatusCompleteHandler);
            });


            $(".btn-copy").click(function(event){

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parents("tr").data('name'));
                });

                $.post("./api/copy" , {"files":files.toString()} );
            });

            $(".btn-move").click(function(event){

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parents("tr").data('name'));
                });

                $.post("./api/move" , {"files":files.toString()} );
            });

            $(".btn-paste").click(function(event){

//                CURSOR.busy();

                $.post("./api/paste").done(function(){
                    alert('completed');
                    $.post("./api/reload" , getStatusCompleteHandler);
                }).always(function(){
//                    CURSOR.normal();
                });

            });

            $(".btn-delete").click(function(event){

                if(!confirm("Do you want delete?")) return;

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parents("tr").data('name'));
                });

                if(files.length == 0)
                {
                    alert("No selected file.")
                    return;
                }

                $.post("./api/delete" , {"files":files.toString()} , function(event){
                    alert('Delete success.');
                    $.post("./api/reload" , getStatusCompleteHandler);
                });
            });

            $(".btn-archive").click(function(event){

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parents("tr").data('name'));
                });

                if(files.length == 0)
                {
                    alert("No selected file.")
                    return;
                }

                $("#form-download > input[name='files']").attr("value" , files.toString());
                $("#form-download").attr("action" , "./api/archive");
                $("#form-download").submit();

            });

            $("#form-upload").submit(function(event){
                $.ajax({
                    url:"./api/upload",
                    type:"post",
                    mimeType: "multipart/form-data",
                    contentType: false,
                    cache: false,
                    processData: false,
                    data: new FormData(this),
                    success:function(event){
                        alert('Upload success.');
                        $.post("./api/reload" , getStatusCompleteHandler);
                    }
                });

                event.preventDefault();
            });


            //btn-addfolder
            $(".btn-addfolder").click(function(event){

                $("#popup").show();

                $("#popup").data("cmd" , "createFolder");
                $("#popup-input-text").val("");

            });

            $("#btn-popup-ok").click(function(event){
                $("#popup").hide();

                switch($("#popup").data("cmd"))
                {
                    case "rename":
                        $.post("./api/rename" , {"name":$("#popup").data("target"), "newName":$("#popup-input-text").val()} , function(event){
                            alert('Rename success.')
                            $.post("./api/reload" , getStatusCompleteHandler);
                        });
                        break;
                    case "createFolder":
                        $.post("./api/createFolder" , {"name":$("#popup-input-text").val()} , function(event){
                            alert('Folder created.')
                            $.post("./api/reload" , getStatusCompleteHandler);
                        });
                        break;
                        break;
                }
            });

            $("#btn-popup-cancel").click(function(event){
               $("#popup").hide();
            });

            $.post("./api/home" , getStatusCompleteHandler);
        });



    </script>
</head>




<body>

    <br><br>

    <div id="top-toolbar-container" style="margin-bottom: 10px">

    </div>

    <br>

    <table class="file-table" style="margin-top: 10px">

        <thead>
            <th style="width: 20px"></th>
            <th style="width: 200px">Name</th>
            <th style="width: 50px">Size</th>
            <th style="width: 50px">Ext</th>
            <th style="width: 100px">Date</th>
            <th style="width: 100px">Actions</th>
        </thead>
        <tbody>


        </tbody>



    </table>

    <br>
    <div id="toolbar">
            <div class="toolbar-button btn-home">
                <img src="/file/image/toolbar/home.png">
                <span>Home</span>
            </div>
            <div class="toolbar-button btn-parent">
                <img src="/file/image/toolbar/goparent.png">
                <span>Go Parent</span>
            </div>
            <div class="toolbar-button btn-addfolder" style="margin-right: 10px">
                <img src="/file/image/toolbar/addfolder.png">
                <span>Add Folder</span>
            </div>
            <div class="toolbar-button btn-copy">
                <img src="/file/image/toolbar/copy.png">
                <span>Copy</span>
            </div>
            <div class="toolbar-button btn-move">
                <img src="/file/image/toolbar/move.png">
                <span>Move</span>
            </div>
            <div class="toolbar-button btn-paste">
                <img src="/file/image/toolbar/paste.png">
                <span>Paste</span>
            </div>
            <div class="toolbar-button btn-delete">
                <img src="/file/image/toolbar/delete.png">
                <span>Delete</span>
            </div>
            <div class="toolbar-button btn-archive">
                <img src="/file/image/toolbar/archive.png">
                <span>Zip Download</span>
            </div>
    </div>
    <br>
    <br>

    <form id="form-upload" action="./api/upload" method="post" target="temp-frame" enctype="multipart/form-data">
        <input type="file" name="file">
        <input type="submit" value="Upload">
    </form>

    </div>
    <br>
    작성자 : 박근영<br>
    본 프로그램은 GPL v3 라이센스의 보호를 받고 있습니다.

    <form id="form-download" action="./api/download" method="post" style="display: none" target="temp-frame">
        <input type="text" name="name">
        <input type="text" name="files">
    </form>

    <div id="popup" class="popup" style="position: absolute;top: 0px;left: 0px;width: 100%;height: 100%;display: none">
        <div style="width: 100%;height: 100%;background-color: black;opacity: 0.4"></div>

        <div id="popup-input" style="left: 50%;top: 50%;width: 300px;height: 150px;margin-left: -150px;margin-top: -75px;background-color: #e2e2e2;position: absolute">
            <div class="popup-title">
                <span>입력</span>
            </div>
            <div class="popup-content">
                <input id="popup-input-text" type="text" style="width: 100%">
                <br>
                <div style="text-align: center;padding-top: 30px">
                    <input id="btn-popup-ok" type="button" style="width: 70px" value="OK">
                    <input id="btn-popup-cancel" type="button" style="width: 70px" value="Cancel">
                </div>
            </div>
        </div>

    </div>

    <iframe name="temp-frame" style="display: none"></iframe>

    <table style="display: none">
        <tr class="row-templete">
            <td class="col-checkbox">
                <input name='select' type='checkbox'>
            </td>
            <td class="col-name">
                <img><span style='padding-left: 5px'></span>
            </td>
            <td class="col-size" style="text-align: right"></td>
            <td class="col-ext"></td>
            <td class="col-date"></td>
            <td class="col-tool">
                <select class="btn-actions" style="width: 100px">
                    <option value="">-- Select --</option>
                    <option value="rename">Rename</option>
                    <option value="download">Download</option>
                </select>
            </td>
        </tr>
    </table>



</body>
</html>
