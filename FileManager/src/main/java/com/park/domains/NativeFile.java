package com.park.domains;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.apache.commons.io.FilenameUtils;

import java.io.File;

/**
 * Created by com on 2016-08-11.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class NativeFile {

    private String name;
    private String extension;
    private long length;
    private boolean isFile;
    private long modified;

    public NativeFile(File file)
    {
        this.name = file.getName();
        this.length = file.length();
        this.isFile = file.isFile();
        this.modified = file.lastModified();

        this.extension = FilenameUtils.getExtension(this.name);
    }

    public String getName() {
        return name;
    }

    public String getExtension() {
        return extension;
    }

    public long getLength() {
        return length;
    }

    public boolean getIsFile() {
        return isFile;
    }

    public long getModified() {
        return modified;
    }
}
