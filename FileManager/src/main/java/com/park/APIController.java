package com.park;

import com.park.domains.NativeFile;
import com.park.domains.Status;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URLEncoder;
import java.nio.file.FileSystems;
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
        retn.setIsRoot(true);
        retn.setFiles(getChildFiles(file));
        return retn;
    }

    @RequestMapping(path = "/api/child" , method = RequestMethod.POST)
    public @ResponseBody Status goChild(HttpSession session , @RequestParam(value = "directory" , required = true) String directory)
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

    @RequestMapping(path = "/api/download" , method = RequestMethod.POST)
    public void download(@RequestParam(value = "name" , required = true) String name, HttpSession session, HttpServletResponse response) throws Exception
    {
        String currentPath = (String) session.getAttribute("current_path");

        File file = new File(currentPath + FileSystems.getDefault().getSeparator() + name);

        assert file.exists() == true;

        String fileName = URLEncoder.encode(file.getName() , "utf-8").replaceAll("\\+" , "%20");

        response.setContentLengthLong(file.length());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\";");
        response.setHeader("Content-Transfer-Encoding", "binary");

        OutputStream out = response.getOutputStream();
        FileInputStream fis = new FileInputStream(file);
        FileCopyUtils.copy(fis, out);

        fis.close();
        out.flush();
    }

    @RequestMapping(path = "/api/upload" , method = RequestMethod.POST)
    public @ResponseBody boolean upload(@RequestParam(value = "file" , required = true) MultipartFile file, HttpSession session) throws Exception
    {
        String fileName = (String) session.getAttribute("current_path") + FileSystems.getDefault().getSeparator() + file.getOriginalFilename();

        ByteArrayInputStream inputStream = new ByteArrayInputStream(file.getBytes());
        FileOutputStream outputStream = new FileOutputStream(fileName);
        FileCopyUtils.copy(inputStream , outputStream);

        inputStream.close();
        outputStream.flush();

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
