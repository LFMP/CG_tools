import 'package:cg_tools/utils/appstyle.dart';
import 'package:flutter/material.dart';

Widget ajudaContexto() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(),
    ),
    child: ListView(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      children: <Widget>[
        ExpansionTile(
          title: Text('Desenhar figuras'),
          children: <Widget>[
            Text(
              'Linha',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('A opcao de desenho selecionada por padrao eh a reta.  ' +
                'Para desenhar um linha pressione o botao flutuante no canto inferior direito. ' +
                'Toque em dois pontos dentro da area com borda preta e uma reta sera desenhada entre eles.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
              'Triangulo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para desenhar um trangulo pressione o botao flutuante no canto inferior direito. ' +
                'Toque em tres pontos dentro da area com borda preta e um triangulo sera desenhado com eles.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
              'Quadrado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para desenhar um quadrado pressione o botao flutuante no canto inferior direito. ' +
                'Toque em dois pontos na diagonal dentro da area com borda preta e um retangulo sera desenhado com eles.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
              'Circulo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para desenhar um circulo pressione o botao flutuante no canto inferior direito. ' +
                'Toque em dois pontos dentro da area com borda preta e um circulo sera desenhado ' +
                'utilizando a distancia entre os pontos como raio.'),
          ],
        ),
        ExpansionTile(
          title: Text('Selecionar objetos'),
          children: <Widget>[
            Text('Selecionar todos'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para selecionar todas as figuras na tela pressione o botao do menu no canto superior direito' +
                ' e toque na opcao "Selecionar tudo" e os elementos selecionados serao destacados.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Selecao individual'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para selecionar invidualmente as figuras pressione o botao representado por um quadrado' +
                ' com um quadrado pontilhado por fora, a lista de figuras ira aparecer ' +
                'junto de suas coordenadas, para selecionar uma figura basta tocar no elemento' +
                ' na lista ou marcar o checkbox e o objeto selecionado sera destacado. ' +
                'Para realizar um selecao eh necessario que exista pelo menos uma figura desenhada.'),
          ],
        ),
        ExpansionTile(
          title: Text('Operacoes'),
          children: <Widget>[
            Text('Rotacao 90 graus'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
                'Para realizar uma rotacao de 90 graus nos objetos selecionados basta pressionar ' +
                    'o primeiro botao na barra inferior.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Rotacao'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para realizar um rotacao de qualquer grau nos objetos selecionar basta pressionar' +
                'o segunda botao na barra inferior, uma janela ira aparecer. ' +
                'Nelas devem ser colocadas as coordenadas a partir de que ponto (X,Y) sera feita ' +
                'a rotacao e qual sera o angulo. Para que a rotacao seja feita basta ' +
                'pressionar o botao de confirmar.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Translacao'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para realizar uma translacao dos objetos selecione toque o' +
                'quarto botao da barra inferior e selecione dois pontos na area delemitada.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Mudanca de escala'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
                'Para realizar a mudanca de escala nos objetos selecionados pressione o quinto ' +
                    'botao na barra inferior, uma janela ira aparecer. ' +
                    'Nela devem ser preenchidos as novas escalas em X e Y.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Limpar tela'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text(
                'Para remover todas as figuras desenhadas basta selecionar a opcao ' +
                    '"Limpar tela" no ultimo botao na barra superior.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Desfazer'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para desfazer uma operacao basta selecionar a opcao' +
                '"Desfazer" no ultimo botao na barra superior.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Refazer'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para refazer uma operacao basta selecionar a opcao' +
                '"Desfazer" no ultimo botao na barra superior.'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Excluir selecionados'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Para remover os objetos selecionados toque no botao de lixeira ' +
                'encontrada ao pressionar o botao flutuante no canto inferior direito.'),
          ],
        ),
        ExpansionTile(
          title: Text('Linha de comando'),
          children: <Widget>[
            Text(
                'Os parametros entre colchetes sao opcionais, os colchetes nao devem ser digitados'),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                  width: 2.0,
                  color: Colors.grey,
                ),
                bottom: BorderSide(
                  width: 2.0,
                  color: Colors.grey,
                ),
              ),
              children: [
                TableRow(
                  children: [
                    Text(
                      'Operacao',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Comando',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Rotacao'),
                    Text('rotate degrees [pX pY]'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Translacao'),
                    Text('translate pX pY'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Mudar escala'),
                    Text('scale sX sY'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Zoom'),
                    Text('zoom p1X p1Y p2X p2Y'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Zoom extend'),
                    Text('zoom 0'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Selecionar'),
                    Text('select indexFigura'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Selecionar tudo'),
                    Text('selectAll'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
