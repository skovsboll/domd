# Build me!

## Building the a and b text files

```yaml
builds:
  - a.txt
  - b.txt
using:
  - lallerkok.txt
```

```typescript(deno)
// all inputs and outputs will be absolute paths at runtime
const outputs = Deno.args.slice(0,1)
const input = Deno.args.slice(2)

const text = await Deno.readTextFile(input)

await Deno.writeTextFile(outputs[0], text.slice(0, text.length / 2));
await Deno.writeTextFile(outputs[1], text.slice(text.length / 2));
```

## Building the lallerkok.txt file

```toml
builds = [
  "lallerkok.txt"
]

using = [
  "fixtures/laller.txt",
  "fixtures/kok.txt"
]
```

```ruby@3.3.0

laller = File.read(ARGV[1])
kok = File.read(ARGV[2])
puts "Concatenating two files..."
File.write ARGV[0], laller + kok
puts "Done."

```