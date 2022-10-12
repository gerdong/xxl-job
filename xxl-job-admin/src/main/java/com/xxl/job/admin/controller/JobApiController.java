package com.xxl.job.admin.controller;

import com.xxl.job.admin.controller.annotation.PermissionLimit;
import com.xxl.job.admin.core.conf.XxlJobAdminConfig;
import com.xxl.job.core.biz.AdminBiz;
import com.xxl.job.core.biz.model.HandleCallbackParam;
import com.xxl.job.core.biz.model.RegistryParam;
import com.xxl.job.core.biz.model.ReturnT;
import com.xxl.job.core.util.GsonTool;
import com.xxl.job.core.util.XxlJobRemotingUtil;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.util.List;

/**
 * Created by xuxueli on 17/5/10.
 */
@Controller
@RequestMapping("/api")
public class JobApiController {

    @Resource
    private AdminBiz adminBiz;

    /**
     * api
     *
     * @param uri
     * @param data
     * @return
     */
    @RequestMapping("/{uri}")
    @ResponseBody
    @PermissionLimit(limit=false)
    public ReturnT<String> api(HttpServletRequest request, @PathVariable("uri") String uri, @RequestBody(required = false) String data) {

        // valid
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            return new ReturnT<String>(ReturnT.FAIL_CODE, "invalid request, HttpMethod not support.");
        }
        if (uri==null || uri.trim().length()==0) {
            return new ReturnT<String>(ReturnT.FAIL_CODE, "invalid request, uri-mapping empty.");
        }
        if (XxlJobAdminConfig.getAdminConfig().getAccessToken()!=null
                && XxlJobAdminConfig.getAdminConfig().getAccessToken().trim().length()>0
                && !XxlJobAdminConfig.getAdminConfig().getAccessToken().equals(request.getHeader(XxlJobRemotingUtil.XXL_JOB_ACCESS_TOKEN))) {
            return new ReturnT<String>(ReturnT.FAIL_CODE, "The access token is wrong.");
        }

        // services mapping
        if ("callback".equals(uri)) {
            List<HandleCallbackParam> callbackParamList = GsonTool.fromJson(data, List.class, HandleCallbackParam.class);
            // !!!当前go executor已经修复此问题，此处仅为兼容老版本准备
            // modified: 2022.04.28 golang 的执行器 xxl-job-executor-go 返回的结构是：
            //      LogID:      req.LogID,
            //		LogDateTim: req.LogDateTime,
            //		ExecuteResult: &ExecuteResult{
            //			Code: code,
            //			Msg:  msg,
            //		},
            // 如：
            //      [{"logId":197,"logDateTim":1651118572188,"executeResult":{"code":200,"msg":"ok"}}]
            // 并不符合这里的定义，因此需要做一个转换
            if (callbackParamList.size() > 0 && callbackParamList.get(0).getHandleCode() == 0) {
                List<HandleCallbackParam2> tmp = GsonTool.fromJson(data, List.class, HandleCallbackParam2.class);
                for (int i = 0; i < tmp.size(); i++) {
                    callbackParamList.get(i).setHandleCode(tmp.get(i).getExecuteResult().getCode());
                    callbackParamList.get(i).setHandleMsg(tmp.get(i).getExecuteResult().getMsg());
                }
            }
            return adminBiz.callback(callbackParamList);
        } else if ("registry".equals(uri)) {
            RegistryParam registryParam = GsonTool.fromJson(data, RegistryParam.class);
            return adminBiz.registry(registryParam);
        } else if ("registryRemove".equals(uri)) {
            RegistryParam registryParam = GsonTool.fromJson(data, RegistryParam.class);
            return adminBiz.registryRemove(registryParam);
        } else {
            return new ReturnT<String>(ReturnT.FAIL_CODE, "invalid request, uri-mapping("+ uri +") not found.");
        }

    }

    class ExecuteResult {
        private int code;
        private String msg;

        public int getCode() {
            return code;
        }

        public void setCode(int code) {
            this.code = code;
        }

        public String getMsg() {
            return msg;
        }

        public void setMsg(String msg) {
            this.msg = msg;
        }
    }

    class HandleCallbackParam2 implements Serializable {
        private long logId;
        private long logDateTim;
        private ExecuteResult executeResult;

        public long getLogId() {
            return logId;
        }

        public void setLogId(long logId) {
            this.logId = logId;
        }

        public long getLogDateTim() {
            return logDateTim;
        }

        public void setLogDateTim(long logDateTim) {
            this.logDateTim = logDateTim;
        }

        public ExecuteResult getExecuteResult() {
            return executeResult;
        }

        public void setExecuteResult(ExecuteResult executeResult) {
            this.executeResult = executeResult;
        }
    }
}
