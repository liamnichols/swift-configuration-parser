# Example

This package provides a very simple example that combines Swift Argument Parser to offer some interesting features.

The main configuration is defined within the `Configuration` type, but **config.json** has also been provided, run the project like so:

```
$ swift run configure-me --config config.json
NOTE: Found unexpected property ‘name‘ while decoding.
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
welcome to my example
```

While the `repeatCount` was set to `10` by default, the greeting was printed `20` times as per the actual configuration file. The message had also changed and you might also notice that the decoder logged an unexpected property too.

Now try running the following command:

```
$ swift run configure-me --config config.json --config-option repeatCount=2 --config-option 'style="uppercase"'
```

You'll see the following

```
NOTE: Found unexpected property ‘name‘ while decoding.
WELCOME TO THIS EXAMPLE
WELCOME TO THIS EXAMPLE
```

Overrides are parsed as `key:value` where `key` is a dot notation path to a property and `value` is a string that can be decoded by the decoder that is configured (`JSONDecoder` by default). The result is a mechanism that is suitable for overriding the configuration when invoking the command.

Finally, try one more option:

```
$ swift run configure-me --config config.json --config-option repeatCount=2 --config-option 'isUppercase=true'
```

You will see the following:

```
NOTE: Property ‘isUppercase‘ is deprecated. Renamed to ‘style‘
NOTE: Found unexpected property ‘name‘ while decoding.
welcome to this example
welcome to this example
```

The `isDeprecated` property was annotated as deprecated so when parsed, will produce an issue that can be processed by your own code.
