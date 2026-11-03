// Example programme document.
//
// Compile from the package root:
//   typst compile --root . examples/programma.typ

#import "../src/lib.typ": (
  programma-didattica,
  modulo,
  quadro,
  sezione,
  sottosezione,
)

#show: programma-didattica.with(
  classe: "1D",
  docente: "Prof. Mattia Marini",
  anno-scolastico: "2026/27",
  ore-annue: 66,
)

#quadro[
  #sezione("COMPETENZE DA RAGGIUNGERE AL TERMINE DELL’ANNO SCOLASTICO")[
    - Saper analizzare un problema e formulare una soluzione algoritmica.
    - Saper utilizzare un foglio di calcolo e le sue funzionalità avanzate.
    - Conoscere i fondamenti della programmazione e scrivere semplici programmi in Python.
  ]
  #sezione("METODOLOGIE DIDATTICHE")[
    - Lezione frontale e dialogata.
    - Esercitazioni in laboratorio, individuali o a coppie.
    - Problem solving guidato, con analisi collettiva degli errori.
  ]
  #sezione("STRUMENTI E CRITERI DI VALUTAZIONE")[
    - Verifiche scritte, pratiche e orali.
    - Sviluppo di progetti individuali o di gruppo.
    - Correttezza, chiarezza e completezza del codice prodotto.
  ]
  #sezione("TESTI, MATERIALI E STRUMENTI ADOTTATI")[
    - Ambiente di sviluppo integrato (IDE): Visual Studio Code.
    - LIM (Lavagna Interattiva Multimediale).
    - Laboratorio di informatica con PC e connessione a Internet.
  ]
]

#modulo("Modulo 1 – Introduzione all’informatica", ore: 5)[
  #sezione("CONOSCENZE E/O CONTENUTI")[
    - Concetto di algoritmo e applicazione a problemi quotidiani.
    - Funzionamento di un computer: bit, byte, memoria e processore.
    - Rappresentazione di numeri, caratteri e istruzioni in codifica binaria.
  ]
  #sezione("ABILITÀ E COMPETENZE")[
    - Riconoscere e classificare i principali componenti hardware di un PC.
    - Comprendere il funzionamento a basso livello di un computer.
    - Rappresentare informazioni in forma binaria.
  ]
]

#modulo("Modulo 2 – Introduzione alla programmazione", ore: 8)[
  #sezione("CONOSCENZE E/O CONTENUTI")[
    #sottosezione("IL LINGUAGGIO PYTHON")
    - Variabili e tipi di dato.
    - Operazioni aritmetiche e booleane di base.
    - Esecuzione condizionale: `if`, `elif`, `else`.
  ]
  #sezione("ABILITÀ E COMPETENZE")[
    - Scrivere semplici programmi in Python.
    - Individuare e correggere semplici errori di sintassi e di esecuzione.
  ]
]
