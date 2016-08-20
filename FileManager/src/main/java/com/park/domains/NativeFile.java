package com.park.domains;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.File;

/**
 * Created by com on 2016-08-11.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class NativeFile {

    private String name;
    private long length;
    private boolean isFile;
    private long modified;

    public NativeFile(File file)
    {
        this.name = file.getName();
        this.length = file.length();
        this.isFile = file.isFile();
        this.modified = file.lastModified();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public long getLength() {
        return length;
    }

    public void setLength(long length) {
        this.length = length;
    }

    public boolean getIsFile() {
        return isFile;
    }

    public void setIsFile(boolean file) {
        isFile = file;
    }

    public long getModified() {
        return modified;
    }

    public void setModified(long modified) {
        this.modified = modified;
    }
}
