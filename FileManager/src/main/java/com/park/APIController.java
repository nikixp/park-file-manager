package com.park;

import com.park.domains.NativeFile;
import com.park.domains.Status;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URLEncoder;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by com on 2016-08-11.
 * 작성자 : 박근영
 * 이메일 : mash9@naver.com
 */
@Controller
public class APIController {

    @Value(value = "${file.explorer.home}")
    private String documentHome;

    @RequestMapping(path = "/")
    public String home()
    {
        return "index";
    }

    @RequestMapping(path = "/api/home" , method = RequestMethod.POST)
    public @ResponseBody Status goHome(HttpSession session)
    {
        session.setAttribute("current_path" , documentHome);

        File file = new File(documentHome);

        Status retn = new Status();
        retn.setIsRoot(true);
        retn.setFiles(getChildFiles(file));
        return retn;
    }

    @RequestMapping(path = "/api/reload" , method = RequestMethod.POST)
    public @ResponseBody Status reload(HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");

        File file = new File(currentPath);

        Status retn = new Status();
        retn.setIsRoot(documentHome.equals(currentPath));
        retn.setFiles(getChildFiles(file));
        return retn;
    }

    @RequestMapping(path = "/api/child" , method = RequestMethod.POST)
    public @ResponseBody Status goChild(HttpSession session , @RequestParam(value = "directory") String directory)
    {
        String currentPath = (String)session.getAttribute("current_path");

        currentPath += FileSystems.getDefault().getSeparator() + directory;



        File file = new File(currentPath);

        Status retn = new Status();
        retn.setIsRoot(documentHome.equals(currentPath));
        retn.setFiles(getChildFiles(file));

        session.setAttribute("current_path" , currentPath);
        return retn;
    }

    @RequestMapping(path = "/api/parent" , method = RequestMethod.POST)
    public @ResponseBody Status goParent(HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");

        if(!documentHome.equals(currentPath))
        {
            currentPath = currentPath.substring(0 , currentPath.lastIndexOf(FileSystems.getDefault().getSeparator()));
        }

        File file = new File(currentPath);

        Status retn = new Status();
        retn.setIsRoot(documentHome.equals(currentPath));
        retn.setFiles(getChildFiles(file));

        session.setAttribute("current_path" , currentPath);
        return retn;
    }

    @RequestMapping(path = "/api/delete" , method = RequestMethod.POST)
    public @ResponseBody boolean delete(@RequestParam(value = "files") List<String> names, HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");

        names.stream().forEach((String name) -> {
            String path = currentPath + FileSystems.getDefault().getSeparator() + name;

            File file = new File(path);

            try
            {
                if(file.isFile())
                    file.delete();
                else
                    FileUtils.deleteDirectory(file);
            }
            catch (IOException ex)
            {

            }

        });

        return true;
    }

    @RequestMapping(path = "/api/rename" , method = RequestMethod.POST)
    public @ResponseBody boolean rename(@RequestParam(value = "name") String name, @RequestParam(value = "newName") String newName, HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");
        File file = new File(currentPath + FileSystems.getDefault().getSeparator() + name);

        assert file.exists();

        file.renameTo(new File(currentPath + FileSystems.getDefault().getSeparator() + newName));
        return true;
    }

    @RequestMapping(path = "/api/createFolder" , method = RequestMethod.POST)
    public @ResponseBody boolean createFolder(@RequestParam(value = "name") String name, HttpSession session) throws Exception
    {
        String currentPath = (String)session.getAttribute("current_path");

        File file = new File(currentPath + FileSystems.getDefault().getSeparator() + name);

        file.mkdir();

        return true;
    }

    @RequestMapping(path = "/api/download" , method = RequestMethod.POST)
    public @ResponseBody boolean download(@RequestParam(value = "name") String name, HttpSession session, HttpServletResponse response) throws Exception
    {
        String currentPath = (String)session.getAttribute("current_path");

        File file = new File(currentPath + FileSystems.getDefault().getSeparator() + name);

        assert file.exists();

        String fileName = URLEncoder.encode(file.getName() , "utf-8").replaceAll("\\+" , "%20");

        response.setContentLengthLong(file.length());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\";");
        response.setHeader("Content-Transfer-Encoding", "binary");

        OutputStream out = response.getOutputStream();
        FileInputStream fis = new FileInputStream(file);
        FileCopyUtils.copy(fis, out);

        fis.close();
        out.flush();

        return true;
    }

    @RequestMapping(path = "/api/upload" , method = RequestMethod.POST)
    public @ResponseBody boolean upload(@RequestParam(value = "file") MultipartFile file, HttpSession session) throws Exception
    {
        String fileName = FilenameUtils.getName(file.getOriginalFilename());
        String path = session.getAttribute("current_path") + FileSystems.getDefault().getSeparator() + fileName;

        ByteArrayInputStream inputStream = new ByteArrayInputStream(file.getBytes());
        FileOutputStream outputStream = new FileOutputStream(path);
        FileCopyUtils.copy(inputStream , outputStream);

        inputStream.close();
        outputStream.flush();
        return true;
    }

    @RequestMapping(path = "/api/copy" , method = RequestMethod.POST)
    public @ResponseBody boolean copy(@RequestParam(value = "files") List<String> names, HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");

        session.setAttribute("command" , "copy");
        session.setAttribute("source_path" , currentPath);
        session.setAttribute("names" , names);
        return true;
    }


    @RequestMapping(path = "/api/move" , method = RequestMethod.POST)
    public @ResponseBody boolean move(@RequestParam(value = "files") List<String> names, HttpSession session)
    {
        String currentPath = (String)session.getAttribute("current_path");

        session.setAttribute("command" , "move");
        session.setAttribute("source_path" , currentPath);
        session.setAttribute("names" , names);
        return true;
    }

    @RequestMapping(path = "/api/paste" , method = RequestMethod.POST)
    public @ResponseBody boolean paste(HttpSession session) throws Exception
    {
        String currentPath = (String)session.getAttribute("current_path");
        String sourcePath = (String)session.getAttribute("source_path");
        String command = (String)session.getAttribute("command");

        List<String> names = (List<String>)session.getAttribute("names");

        for(String name : names)
        {
            File sourceFile = new File(sourcePath + FileSystems.getDefault().getSeparator() + name);


            if(sourceFile.isFile())
            {
                File targetFile = new File(currentPath + FileSystems.getDefault().getSeparator() + name);

                if("copy".equals(command))
                    FileUtils.copyFile(sourceFile , targetFile);
                else if("move".equals(command))
                    FileUtils.moveFile(sourceFile , targetFile);
            }
            else
            {
                File targetPath = new File(currentPath);

                if("copy".equals(command))
                    FileUtils.copyDirectoryToDirectory(sourceFile , targetPath);
                else if("move".equals(command))
                    FileUtils.moveDirectoryToDirectory(sourceFile , targetPath , true);
            }


        }

        return true;
    }

    protected List<NativeFile> getChildFiles(File file)
    {
        ArrayList<NativeFile> files = new ArrayList();

        for(File child : file.listFiles())
        {
            if(child.isHidden()) continue;
            files.add(new NativeFile(child));
        }

        return files;
    }


}
