import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:papeeta/models/mensajes_response.dart';

import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/services/chat_service.dart';
import 'package:papeeta/services/socket_service.dart';

import 'package:papeeta/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  final List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket
        .on('mensaje-personal', (data) => _escucharMensaje(data));
    _cargarHistorial(chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioId) async {
    List<Mensaje> chat = await chatService.getChat(usuarioId);

    final history = chat.map(
      (m) => ChatMessage(
        texto: m.mensaje,
        uid: m.de,
        animationController: AnimationController(
            vsync: this, duration: const Duration(milliseconds: 0))
          ..forward(),
      ),
    );

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      texto: payload['mensaje'],
      uid: payload['de'],
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    message.animationController.forward();

    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final usuarioPara = chatService.usuarioPara;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
              child: Text(usuarioPara.nombre.substring(0, 2),
                  style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 3),
            Text(usuarioPara.nombre,
                style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
              reverse: true,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 0),
                    blurRadius: 2,
                    spreadRadius: 0),
              ],
            ),
            child: _inputChat(),
          )
        ],
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String texto) {
                  setState(() {
                    if (texto.trim().isNotEmpty) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar mensaje',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                focusNode: _focusNode,
              ),
            ),

            //Botón de enviar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _estaEscribiendo
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                      child: const Text('Enviar'),
                    )
                  : IconTheme(
                      data: IconThemeData(color: Colors.blue[400]),
                      child: IconButton(
                        onPressed: _estaEscribiendo
                            ? () => _handleSubmit(_textController.text.trim())
                            : null,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: const Icon(Icons.send),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String texto) {
    if (texto.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      texto: texto,
      uid: authService.usuario.uid,
      animationController: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();
    setState(() {
      _estaEscribiendo = false;
    });

    //Emitir mensaje al servidor
    socketService.socket.emit('mensaje-personal', {
      'de': authService.usuario.uid,
      'para': chatService.usuarioPara.uid,
      'mensaje': texto
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
