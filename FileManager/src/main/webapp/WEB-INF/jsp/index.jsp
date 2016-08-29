<%--
  Created by IntelliJ IDEA.
  User: park
  Date: 2016-08-11
  Time: 오후 6:26
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<head>
    <title>:: 파일 탐색기 1.0::</title>
    <link rel="stylesheet" type="text/css" href="./css/default.css">
    <script src="./js/jquery/jquery-3.1.0.min.js"></script>
    <script type="text/javascript">

        $(document).ready(function() {

            // Handler for .ready() called.
            //alert('ready2');

            function getStatusCompleteHandler(data)
            {
                $("table.file-table > tbody > tr").remove();

                $("#btn-parent").attr("disabled" , data.isRoot);

                data.files.sort(function(item1 , item2){return item1.isFile - item2.isFile;}).forEach(function(item){

                    var newRow = $("<tr><td></td><td></td><td></td><td></td><td></td><td></td></tr>");
                    newRow.data("name" , item.name);
                    newRow.data("isFile" , item.isFile);


                    var checkBox = $("<input name='select' type='checkbox'>");

                    newRow.find("td:nth-child(1)").append(checkBox);


                    var itemImage = $("<img>");


                    if(item.isFile == false)
                        itemImage.attr("src" , "./image/folder.png");
                    else
                        itemImage.attr("src" , "./image/file.png");


                    newRow.find("td:nth-child(2)").append(itemImage);


                    var itemName = $("<span style='padding-left: 5px'></span>");
                    itemName.html(item.name);
                    //itemName.css("cursor" , "hand");

                    newRow.find("td:nth-child(2)").attr("class" , "file-name");
                    newRow.find("td:nth-child(2)").append(itemName);
                    newRow.find("td:nth-child(2)").click(function(event){

                        //alert( $(event.currentTarget).parent().data("isFile") );

                        var name = $(event.currentTarget).parent().data("name");

                        var isFile = $(event.currentTarget).parent().data("isFile");

                      // if(isFile)
                       //    $.post("./api/download" , {"name":name} , fu);
                        //else
                        if(isFile == false)
                        {
                           $.post("./api/child" , {"directory":name} , getStatusCompleteHandler);
                        }
                        else
                        {
                            $("#form-download > input[name='name']").attr("value" , name);
                            //$("#form-download-name").attr("value" , name);

                            $("#form-download").submit();
                            //form-download.tar
                            //form-download
                        }

                       //$.post("./api/child" , {"directory":$(event.currentTarget).data("directory")} , getStatusCompleteHandler);
                       //$.post("./api/child" , {"directory":directory} , getStatusCompleteHandler);
                    });


                    newRow.find("td:nth-child(3)").html(item.length);

                    var renameBtn = $("<input type='button' value='Rename'>");

                    renameBtn.click(function(event){

                        //popup-input
                        $("#popup").show();


                        var name = $(event.currentTarget).parent().parent().data("name");

                        $("#popup").data("cmd" , "rename");
                        $("#popup").data("target" , name);

                        $("#popup-input-text").val(name);
                    });

                    //popup-input

                    newRow.find("td:nth-child(6)").append(renameBtn);

                    $("table.file-table > tbody").append(newRow);
                });

                $("table.file-table > tbody > tr:even").addClass("even-class");
            };

            $("#btn-parent").click(function(event){
                $.post("./api/parent" , getStatusCompleteHandler);
            });

            $("#btn-home").click(function(event){
                $.post("./api/home" , getStatusCompleteHandler);
            });


            $("#btn-copy").click(function(event){

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parent().parent().data('name'));
                });

                $.post("./api/copy" , {"files":files.toString()} );
            });

            $("#btn-move").click(function(event){

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parent().parent().data('name'));
                });

                $.post("./api/move" , {"files":files.toString()} );
            });

            $("#btn-paste").click(function(event){

                $('html, body').css("cursor", "wait");

                $.post("./api/paste" , function(event){
                    alert('completed');

                    $('html, body').css("cursor", "auto");

                    $.post("./api/reload" , getStatusCompleteHandler);
                });
            });

            $("#btn-delete").click(function(event){

                if(!confirm("Do you want delete?")) return;

                var files = [];

                $("table.file-table input[name='select']:checked").each(function(index , checkbox){

                    files.push($(checkbox).parent().parent().data('name'));
                });

                $.post("./api/delete" , {"files":files.toString()} , function(event){
                    alert('Delete success.');
                    $.post("./api/reload" , getStatusCompleteHandler);
                });
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
            $("#btn-addfolder").click(function(event){

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

                //$("#popup").data("cmd" , "rename");
                //$("#popup").data("target" , name);

            });

            $("#btn-popup-cancel").click(function(event){
               $("#popup").hide();
            });

            $.post("./api/home" , getStatusCompleteHandler);
        });



    </script>
</head>




<body>

    파일탐색기 1.0<br><br>

    <table class="file-table">

        <thead>
            <th style="width: 20px"></th>
            <th style="width: 200px">Name</th>
            <th style="width: 50px">Size</th>
            <th style="width: 50px">Type</th>
            <th style="width: 100px">Date</th>
            <th style="width: 100px"></th>
        </thead>
        <tbody>

        </tbody>



    </table>

    <br>
    <input id="btn-home" type="button" value="Home">
    <input id="btn-parent" type="button" value="Go Parent">
    <input id="btn-delete" type="button" value="Delete">
    <input id="btn-addfolder" type="button" value="Add Folder">
    <input id="btn-copy" type="button" value="Copy">
    <input id="btn-move" type="button" value="Move">
    <input id="btn-paste" type="button" value="Paste">
    <br>
    <br>

    <form id="form-upload" action="./api/upload" method="post" target="temp-frame" enctype="multipart/form-data">
        <input type="file" name="file">
        <input type="submit" value="Upload">
    </form>

    </div>
    <br>
    제작자 : 박근영<br>
    본 프로그램은 GPL v3 라이센스의 보호를 받고 있습니다.

    <form id="form-download" action="./api/download" method="post" style="display: none" target="temp-frame">
        <input type="text" name="name">
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

</body>
</html>
