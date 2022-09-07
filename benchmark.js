var fs = require("fs");
var exec_sync = require("child_process").execSync;

var SMALL = false;

var run = [
  "haskell",
  "kind2",
  "agda",
  "idris",
  "coq",
  "lean",
];

let allowed_tests = {
  list_fold: true,
  nat_exp: true,
  nat_exp_church: true,
  tree_fold_church: true,
  vector: true,
  quicksort: true,
  composition: true,
}

var langs = {

  haskell: {
    runtime: {
      tasks: {
        list_fold: [1,64],
        tree_fold: [26,32],
        quicksort: [0, 15],
        composition: [10, 32],
      },
      build: (task) => {
        save("main.hs", load("Runtime/"+task+".hs"));
        exec("ghc -O2 main.hs -o main.bin");
      },
      bench: (task, size) => {
        return bench("./main.bin " + size);
      },
      clean: () => {
        rm("main.hs");
        rm("main.hi");
        rm("main.o");
        rm("main.bin");
      },
    }
  },

  kind2: {
    runtime: {
      tasks: {
        list_fold: [1,64],
        tree_fold: [26,32],
        quicksort: [0, 15],
        composition: [10, 32],
      },
      build: (task) => {
        save("main.kind2", load("Runtime/"+task+".kind2"));
        exec("kind2 to-hvm main.kind2 >> main.hvm");
        exec("hvm compile main.hvm");
        exec("clang -O2 main.c -o main.bin");
      },
      bench: (task, size) => {
        return bench("./main.bin " + size + " 2>/dev/null");
      },
      clean: () => {
        rm("main.kind2");
        rm("main.c");
        rm("main.hvm");
        rm("main.bin");
      },
    },
    checker: {
      tasks: {
        nat_exp: [10,15],
        nat_exp_church: [16,24],
        tree_fold: [16,24],
        tree_fold_church: [16,24],
        vector: [1, 4],
      },
      build: (task) => {
        save("Base.kind2", load("Checker/Base.kind2"));
      },
      bench: (task, size) => {
        var code = load("Checker/"+task+".kind2");
        code = code.replace("Size = Base.N1", "Size = Base.N" + size);
        code = code.replace("Size = Base.Church.N1", "Size = Base.Church.N" + size);
        code = repeat(code, "//REPEAT", 2 ** size);
        save("main.kind2", code);
        exec("kind2 gen-checker main.kind2");
        return bench("hvm --memory-size 12G run main.check.hvm 2>/dev/null");
      },
      clean: (task) => {
        rm("Base.kind2");
        rm("main.kind2");
        rm("main.check.hvm");
      },
    }
  },

  agda: {
    checker: {
      tasks: {
        nat_exp: [10,14],
        nat_exp_church: [16,24],
        tree_fold: [16,24],
        tree_fold_church: [16,24],
        vector: [1,4],
      },
      build: (task) => {
        save("Base.agda", load("Checker/Base.agda"));
      },
      bench: (task, size) => {
        var code = load("Checker/"+task+".agda");
        code = code.replace("Size = Base.N1", "Size = Base.N" + size);
        code = code.replace("Size = Base.Church-N1", "Size = Base.Church-N" + size);
        code = repeat(code, "--REPEAT", 2 ** size);
        save("main.agda", code);
        return bench("agda -i src main.agda");
      },
      clean: () => {
        rm("main.agda");
        rm("Base.agda");
        rm("main.agdai");
        rm("Base.agdai");
      },
    }
  },

  idris: {
    checker: {
      tasks: {
        nat_exp: [10,13],
        nat_exp_church: [16,21],
        tree_fold: [16,24],
        tree_fold_church: [16,21],
        vector: [1, 4],
      },
      build: (task) => {
        save("Base.idr", load("Checker/Base.idr"));
      },
      bench: (task, size) => {
        var code = load("Checker/"+task+".idr");
        code = code.replace("Size = Base.N1", "Size = Base.N" + size);
        code = code.replace("Size = Base.Church_N1", "Size = Base.Church_N" + size);
        code = repeat(code, "--REPEAT", 2 ** size);
        save("main.idr", code);
        return bench("idris2 main.idr -c");
      },
      clean: () => {
      },
    }
  },

  coq: {
    checker: {
      tasks: {
        nat_exp: [10,15],
        nat_exp_church: [16,24],
        tree_fold: [16,24],
        tree_fold_church: [16,24],
        vector: [1, 4],
      },
      build: (task) => {
        save("Base.v", load("Checker/Base.v"));
      },
      bench: (task, size) => {
        var code = load("Checker/"+task+".v");
        code = code.replace("Definition Size : Base.Nat := Base.N1 .", "Definition Size : Base.Nat := Base.N" + size + " .");
        code = code.replace("Definition Size : Base.Church_Nat := Base.Church_N1 .", "Definition Size : Base.Church_Nat := Base.Church_N" + size + " .");
        code = repeat(code, "(* REPEAT *)", 2 ** size);
        save("main.v", code);
        return bench("coqc main.v");
      },
      clean: () => {
      },
    }
  },

  lean: {
    checker: {
      tasks: {
        nat_exp: [10,14],
        nat_exp_church: [16,24],
        tree_fold: [16,24],
        tree_fold_church: [16,24],
        vector: [1, 4],
      },
      build: (task) => {
      },
      bench: (task, size) => {
        var code = load("Checker/"+task+".lean");
        var base = load("Checker/Base.lean");
        code = code.replace("Size : Base.Nat := Base.N1", "Size : Base.Nat := Base.N" + size);
        code = code.replace("Size : Base.Church.Nat := Base.Church.N1", "Size : Base.Church.Nat := Base.Church.N" + size);
        code = repeat(code, "--REPEAT", 2 ** size);
        code = base + "\n---\n" + code;
        save("main.lean", code);
        return bench("lean main.lean");
      },
      clean: () => {
      },
    }
  },
};

for (var name in langs) {
  for (var kind in langs[name]) {
    langs[name][kind].clean();
  }
}

var results = [];

for (var lang of run) {
  for (var kind in langs[lang]) {
    for (var task in langs[lang][kind].tasks) {
      if(!allowed_tests[task]) continue;

      langs[lang][kind].clean(task);
      langs[lang][kind].build(task);
      var min_size = langs[lang][kind].tasks[task][0];
      var max_size = SMALL ? min_size + 2 : langs[lang][kind].tasks[task][1];
      for (var size = min_size; size <= max_size; ++size) {
        if (size === min_size) {
          langs[lang][kind].bench(task, size); // dry-run to heat up
        }
        var time = langs[lang][kind].bench(task, size);
        results.push([kind, task, lang, size, time]);
        console.log(kind + " | " + task + " | " + lang + " | " + size + " | " + time.toFixed(3) + "s");
      }
      langs[lang][kind].clean(task);
    }
  }
}

fs.writeFileSync("./results.json", JSON.stringify(results, null, 2));

function exec(str) {
  try {
    return exec_sync(str).toString();
  } catch (e) {
    console.log(e.stdout.toString());
    console.log(e.stderr.toString());
    return Infinity;
  }
}

function load(name) {
  return fs.readFileSync(name, "utf8");
}

function save(name, text) {
  fs.writeFileSync(name, text);
}

function rm(name) {
  if (fs.existsSync(name)) {
    fs.unlinkSync(name);
  }
}

function repeat(code, label, size) {
  var new_code = "";
  for (var line of code.split("\n")) {
    var times = line.indexOf("--REPEAT") !== -1 ? size : 1;
    for (var i = 0; i < times; ++i) {
      new_code = new_code + line + "\n";
    }
  }
  return new_code;
}

function bench(cmd) {
  var ini = Date.now();
  var res = exec(cmd, {skipThrow: 1}).toString().replace(/\n/g,"");
  //console.log(">> done: " + res.substring(0, 100));
  if (res == Infinity) { return Infinity }
  var end = Date.now();
  return (end - ini) / 1000;
}

