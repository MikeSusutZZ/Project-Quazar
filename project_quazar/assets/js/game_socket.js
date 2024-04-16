import { Socket } from "phoenix";

let socket = new Socket("/game", { params: { token: window.userToken } });

socket.connect();

export default socket;
