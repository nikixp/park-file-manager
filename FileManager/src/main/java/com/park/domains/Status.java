package com.park.domains;

import java.util.List;

/**
 * Created by com on 2016-08-11.
 */
public class Status {

    private boolean isRoot;
    private List<NativeFile> files;

    public boolean getIsRoot() {
        return isRoot;
    }

    public void setIsRoot(boolean root) {
        isRoot = root;
    }

    public List<NativeFile> getFiles() {
        return files;
    }

    public void setFiles(List<NativeFile> files) {
        this.files = files;
    }
}
