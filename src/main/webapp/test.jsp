<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.*"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>cometd集群测试</title>
<script src="<%=request.getContextPath()%>/js/jquery/jquery-1.12.4.js"></script>
<script src="<%=request.getContextPath()%>/js/cometd/cometd.js"></script>
<script src="<%=request.getContextPath()%>/js/cometd/jquery.cometd.js"></script>
<script  type="text/javascript">
jQuery(function($) {
	var cometd = $.cometd;
	$("#connect").click(function(){
		function _connectionEstablished() {
			$('#body').append('<div>CometD Connection Established</div>');
		}

		function _connectionBroken() {
			$('#body').append('<div>CometD Connection Broken</div>');
		}

		function _connectionClosed() {
			$('#body').append('<div>CometD Connection Closed</div>');
		}

		// Function that manages the connection status with the Bayeux
		// server
		var _connected = false;
		// 检测会话连接是否建立
		function _metaConnect(message) {
			if (cometd.isDisconnected()) {
				_connected = false;
				_connectionClosed();
				return;
			}

			var wasConnected = _connected;
			_connected = message.successful === true;
			if (!wasConnected && _connected) {
				_connectionEstablished();
			} else if (wasConnected && !_connected) {
				_connectionBroken();
			}
		}

		// Function invoked when first contacting the server and
		// when the server has lost the state of this client
		var loop = 0;
		function _metaHandshake(handshake) {
			if (handshake.successful === true) {
				alert("连接成功！");
				cometd.batch(function() {		
					cometd.subscribe('/chat/' + $("#room").val(),function(message){
						var data = message.data;
						$("#chatBoard").append("<li>"+message.data.msg+ "<br></li>");
					});
				});
			}
		}

		// Disconnect when the page unloads
		$(window).unload(function() {
			cometd.disconnect(true);
		});
		var cometURL = $("#ip").val()+"/<%=request.getContextPath()%>/cometd";
		cometd.configure({
			url : cometURL,
			logLevel : 'debug',
		});
		// 进行握手
		cometd.addListener('/meta/handshake', _metaHandshake);
		// 建立连接
		// cometd.addListener('/meta/connect', _metaConnect);
		cometd.handshake();
		
	});
	
	$(document).keydown(function(event){
		if(event.keyCode == 13){
			$("#send").click();
		}
	});
	$("#send").click(function(){	
		if($("#msg").val() == ""){
			alert("请输入聊天内容");
			return;
		}
		var message = {};
		message.msg = $("#msg").val();
		message.room = $("#room").val();
		$("#msg").val("");
		cometd.publish('/service/chat', message);//
	})
});
</script>
<script src="<%=request.getContextPath()%>/lib/js/bootstrap.min.js"></script>
<link href="<%=request.getContextPath()%>/lib/css/bootstrap.css" rel="stylesheet">
</head>
<body>
	<h3 style="padding-left:200px">聊天室</h3>
	<br>
 	<div class="form-group col-sm-8">
 		<div class="col-sm-6">
 			<input id="ip" type="text" class="form-control" placeholder="请输入服务地址" required="required">
 		</div>
 		<div class="col-sm-2">
 			<input id="room" type="text" class="form-control" placeholder="聊天室编号" required="required">
 		</div>
		<button id="connect" class="btn btn-danger">&nbsp;&nbsp;连&nbsp;接&nbsp;&nbsp;</button>&nbsp;&nbsp;&nbsp;&nbsp;
	</div>
	<div class="form-group col-sm-8">
	<div class="col-sm-12">
	(提示:若更换服务地址，请刷新后重新输入！服务地址包括schema和port，例如[http://localhost:8080])
	</div>
	<div class="col-sm-12">
	http://localhost:8080
	</div>
	</div>
	<div class="msg" style="padding-left:30px">
		<ul id="chatBoard"  class="chat-thread" style="width:100%;height:300px;overflow:auto;padding-left: 30px;">
		</ul>
		<div class="send-msg" style="width:100%">
			<input id="msg" type="text" class="form-control" placeholder="请输入内容" required="required">
			<button id="send" class="btn btn-primary">&nbsp;&nbsp;发&nbsp;送&nbsp;&nbsp;</button>
		</div>
	</div>

</body>
<style>
#chatBoard{
	padding:20px;
	height: 240px;
	width:970px;
	border: 1px solid #ccc;
	border-bottom: none;
}

.chat-thread {
  margin: 0px;
  border-top-left-radius:5px;
  border-top-right-radius:5px;
 }
 
.send-msg{
	border-bottom-left-radius:5px;
	border-bottom-right-radius:5px;
}
.msg{
	width: 980px;
	height: 200px;
	float:left;
	margin-top: 15px;
	margin-bottom:20px;
}

.msg div{
	margin-right: 10px;
	border: 1px solid #ccc;
}
.msg div:nth-child(1){
	height: 240px;
	border: 1px solid #ccc;
	border-bottom: none;
}
.msg div:nth-child(2){
	height: 60px;
	border: 1px solid #ccc;
	padding: 15px 15px;
	line-height:50px;
}
.msg input{
	float:left;
	width: 88%;
	margin-right:20px;
}
</style>
</html>