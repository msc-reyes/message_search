class Message {
  final int? id;
  final String title;
  final DateTime date;
  final String preacher;
  final String location;
  final String content;
  final String pdfPath;

  Message({
    this.id,
    required this.title,
    required this.date,
    required this.preacher,
    required this.location,
    required this.content,
    required this.pdfPath,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'preacher': preacher,
      'location': location,
      'content': content,
      'pdf_path': pdfPath,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      preacher: map['preacher'] as String,
      location: map['location'] as String,
      content: map['content'] as String,
      pdfPath: map['pdf_path'] as String,
    );
  }

  // Copiar con nuevos valores
  Message copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? preacher,
    String? location,
    String? content,
    String? pdfPath,
  }) {
    return Message(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      preacher: preacher ?? this.preacher,
      location: location ?? this.location,
      content: content ?? this.content,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}

// Datos dummy para pruebas (actualizados con preacher y location)
class DummyData {
  static List<Message> getMessages() {
    return [
      Message(
        id: 1,
        title: "El Fundamento de Nuestra Fe",
        date: DateTime(2010, 3, 5),
        preacher: "Predicado por el Hno. Bernabé G. García",
        location: "En Phoenix, Arizona U.S.A",
        content: """Vamos a ponernos de pie para leer la Palabra.

El fundamento de nuestra fe está en Jesucristo. 
        
Él es la roca sobre la cual edificamos nuestra vida espiritual. En Mateo 7:24-25 leemos: "Cualquiera, pues, que me oye estas palabras, y las hace, le compararé a un hombre prudente, que edificó su casa sobre la roca."

La fe no es simplemente un sentimiento o una creencia pasajera, sino una confianza firme en Dios y en Su Palabra. Es creer que Dios es quien dice ser y que hará lo que ha prometido.

Cuando construimos sobre este fundamento sólido, nuestra vida puede resistir las tormentas y dificultades. El Señor es nuestra roca, nuestra fortaleza y nuestro libertador.

Recordemos siempre que Él es fiel y verdadero, y que Su amor por nosotros nunca cambia. En tiempos de prueba, podemos confiar en que Él está con nosotros y nos sostiene con Su mano poderosa.""",
        pdfPath: "mensaje_001.pdf",
      ),
      Message(
        id: 2,
        title: "La Gracia Transformadora de Dios",
        date: DateTime(2010, 8, 15),
        preacher: "Predicado por el Hno. Bernabé G. García",
        location: "En Phoenix, Arizona U.S.A",
        content: """Vamos a ponernos de pie para leer la Palabra.

La gracia de Dios es verdaderamente transformadora.

No es algo que podamos ganar o merecer, sino un regalo divino que nos es dado por amor. Efesios 2:8-9 nos dice: "Porque por gracia sois salvos por medio de la fe; y esto no de vosotros, pues es don de Dios; no por obras, para que nadie se gloríe."

Esta gracia no solo nos salva, sino que también nos transforma día a día. Nos capacita para vivir una vida que honra a Dios y bendice a otros. Es por Su gracia que podemos levantarnos después de caer, que podemos perdonar cuando hemos sido heridos, y que podemos amar cuando es difícil hacerlo.

La gracia de Dios es suficiente para todas nuestras necesidades. En nuestra debilidad, Su poder se perfecciona. No importa cuán grande sea nuestro pecado o cuán profunda sea nuestra necesidad, Su gracia es más que suficiente.

Vivamos cada día agradecidos por esta gracia maravillosa que nos ha sido dada. Que nuestra vida sea un testimonio del poder transformador del amor de Dios.""",
        pdfPath: "mensaje_002.pdf",
      ),
      Message(
        id: 3,
        title: "El Amor de Dios Manifestado",
        date: DateTime(2011, 2, 20),
        preacher: "Predicado por el Hno. Bernabé G. García",
        location: "En Phoenix, Arizona U.S.A",
        content: """Vamos a ponernos de pie para leer la Palabra.

El amor de Dios ha sido manifestado de muchas maneras.

Juan 3:16 nos revela la máxima expresión de Su amor: "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna."

Este amor no es abstracto o distante. Es un amor personal, íntimo y activo. Dios no solo nos ama desde lejos; Él se involucra en nuestra vida diaria. Conoce nuestros pensamientos, nuestras luchas y nuestros anhelos más profundos.

El amor de Dios es paciente y bondadoso. No lleva cuenta de nuestras faltas. Siempre protege, siempre confía, siempre espera y siempre persevera. Este amor nunca falla.

Cuando entendemos la profundidad del amor de Dios por nosotros, nuestra vida cambia radicalmente. Ya no vivimos para nosotros mismos, sino para Aquel que nos amó y se entregó por nosotros.

Que podamos experimentar cada día más de este amor incomparable. Que nuestro corazón sea lleno de Su amor para que podamos amar a otros de la misma manera.""",
        pdfPath: "mensaje_003.pdf",
      ),
      Message(
        id: 4,
        title: "La Fidelidad de Dios en Tiempos Difíciles",
        date: DateTime(2012, 6, 10),
        preacher: "Predicado por el Hno. Bernabé G. García",
        location: "En Phoenix, Arizona U.S.A",
        content: """Vamos a ponernos de pie para leer la Palabra.

La fidelidad de Dios permanece constante, especialmente en tiempos difíciles.

Lamentaciones 3:22-23 nos recuerda: "Por la misericordia de Jehová no hemos sido consumidos, porque nunca decayeron sus misericordias. Nuevas son cada mañana; grande es tu fidelidad."

Cuando atravesamos valles oscuros, cuando enfrentamos situaciones que parecen imposibles, es ahí donde la fidelidad de Dios brilla con mayor intensidad. Él no nos abandona en la tormenta; Él camina con nosotros a través de ella.

Job experimentó pruebas tremendas, pero al final pudo declarar: "Yo conozco que todo lo puedes, y que no hay pensamiento que se esconda de ti." Dios fue fiel a Job, restaurando todo lo que había perdido y más.

La fidelidad de Dios no depende de nuestras circunstancias ni de nuestro desempeño. Es parte de Su carácter inmutable. Él es el mismo ayer, hoy y por los siglos.

En momentos de duda, recordemos las veces que Él nos ha sostenido. Cada prueba superada es un testimonio de Su fidelidad. Confiemos en que Él completará la buena obra que comenzó en nosotros.""",
        pdfPath: "mensaje_004.pdf",
      ),
      Message(
        id: 5,
        title: "Viviendo en el Espíritu",
        date: DateTime(2013, 11, 3),
        preacher: "Predicado por el Hno. Bernabé G. García",
        location: "En Phoenix, Arizona U.S.A",
        content: """Vamos a ponernos de pie para leer la Palabra.

Vivir en el Espíritu es más que una doctrina; es una realidad diaria.

Gálatas 5:16 nos instruye: "Digo, pues: Andad en el Espíritu, y no satisfagáis los deseos de la carne." Esta es una invitación a una vida guiada y empoderada por el Espíritu Santo.

El Espíritu Santo no es una fuerza impersonal, sino la tercera persona de la Trinidad que vive en cada creyente. Él nos guía a toda verdad, nos consuela en la aflicción, intercede por nosotros y nos da poder para vivir una vida santa.

Cuando caminamos en el Espíritu, Su fruto se manifiesta en nuestra vida: amor, gozo, paz, paciencia, benignidad, bondad, fe, mansedumbre y templanza. Estas cualidades no las producimos por esfuerzo propio, sino que son el resultado natural de rendirnos al control del Espíritu.

Vivir en el Espíritu también significa ser sensibles a Su dirección. Él nos habla a través de la Palabra, de la oración y de esa voz apacible y delicada en nuestro corazón.

Cultivemos una relación íntima con el Espíritu Santo. Aprendamos a escuchar Su voz y a obedecer Su guía. En Él encontramos todo lo que necesitamos para vivir una vida victoriosa.""",
        pdfPath: "mensaje_005.pdf",
      ),
    ];
  }
}
