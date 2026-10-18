using System;
using System.IO;
using System.Net.Http;
using System.Net.Sockets;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
public class NativeMainRpc {
 public static async Task<string> Read(string path,string id,string turnId=null) {
  using var cts=new CancellationTokenSource(10000);
  using var handler=new SocketsHttpHandler();
  handler.ConnectCallback=async (context,token)=>{var sock=new Socket(AddressFamily.Unix,SocketType.Stream,ProtocolType.Unspecified);await sock.ConnectAsync(new UnixDomainSocketEndPoint(path),token);return new NetworkStream(sock,true);};
  using var invoker=new HttpMessageInvoker(handler);
  using var ws=new ClientWebSocket();
  await ws.ConnectAsync(new Uri("ws://localhost/"),invoker,cts.Token);
  await Request(ws,1,"initialize",new {clientInfo=new {name="always_on_recovery",version="1"},capabilities=new {experimentalApi=true}},cts.Token);
  await Send(ws,new {method="initialized"},cts.Token);
  if(turnId=="settings")return await Request(ws,2,"thread/resume",new {threadId=id},cts.Token);

  if(turnId!=null)return await Request(ws,2,"turn/interrupt",new {threadId=id,turnId},cts.Token);
  return await Request(ws,2,"thread/read",new {threadId=id,includeTurns=true},cts.Token);
 }
 static async Task Send(ClientWebSocket ws,object obj,CancellationToken ct){var bytes=Encoding.UTF8.GetBytes(JsonSerializer.Serialize(obj));await ws.SendAsync(new ArraySegment<byte>(bytes),WebSocketMessageType.Text,true,ct);}
 static async Task<string> Request(ClientWebSocket ws,int id,string method,object pars,CancellationToken ct){
  await Send(ws,new {id,method,@params=pars},ct);
  while(true){using var ms=new MemoryStream();WebSocketReceiveResult r;var buffer=new byte[8192];do{r=await ws.ReceiveAsync(new ArraySegment<byte>(buffer),ct);if(r.MessageType==WebSocketMessageType.Close)throw new Exception("closed");ms.Write(buffer,0,r.Count);}while(!r.EndOfMessage);var text=Encoding.UTF8.GetString(ms.ToArray());using var json=JsonDocument.Parse(text);if(json.RootElement.TryGetProperty("id",out var rid)&&rid.ValueKind==JsonValueKind.Number&&rid.GetInt32()==id)return text;}
 }
}