# Cue Leaves Issue

This repository outlines the following issue:

With the schemas in the root, and the data in the leaves for different `pipeline` definitions.

The intent is to output to three different files:

- `a.yml`: describing rules for pipeline `a`
- `b.yml`: describing rules for pipeline `b`
- `generic.yml`: describing shared rules for `a` and `b`

This works fine when writing a script to output each of these using cue scripting (omitted), with `generic` not taking any data from `a` or `b`.

When trying to generate a configuration with labels based on a combination of both definitions of `pipeline` in the leaves `a` and `b`, each leaf results in a separate definition:

```cue
_monitored_pipelines_label: "(" + strings.Join([ for k, v in pipeline {v.name}], "|") + ")"
```

results in:

```shell
❯ cue eval ./config/pipelines/... -e _monitored_pipelines_label
"()"
// ---
"(a)"
// ---
"(b)"
```

I feel I’m conceptually misunderstanding something here, it looks like each leaf, and then also something else (`[]`) is being evaluated separately? I’d expected this to result:

```shell
(a|b)
```
