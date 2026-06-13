new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out1;
struct olsmtOut out2;

ctl = olsmtControlCreate;
ctl.output = 0;

fname = getGAUSSHome() $+ "examples/auto.dat";
out1 = olsmt(ctl, fname, "mpg ~ weight + length");
out2 = olsmt(ctl, fname, "mpg ~ weight + length");

struct ptModel models;
models = reshape(ptModelFrom("Model 1", out1), 2, 1);
models[2] = ptModelFrom("Model 2", out2);

struct ptTable tbl;
tbl = ptModelCompare(models);
tbl = ptSetTitle(tbl, "Model Comparison");

call ptExport(tbl, "model_comparison.md");
call ptExport(tbl, "model_comparison.rtf");
