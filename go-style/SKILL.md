---
name: go-style
description: Go code style, idioms, and patterns. Use when writing, reviewing, or refactoring Go code. Covers naming, error handling, concurrency, interfaces, project structure, and testing.
---

# Go Style

## Formatting

- `gofmt` — non-negotiable, no manual formatting
- Tabs for indentation
- No line length limit, but break long function signatures after opening paren

## Naming

- `MixedCaps` for exported, `mixedCaps` for unexported — no underscores
- Short names for short scopes: `i`, `r`, `ctx`, `err`
- Descriptive names for package-level and exported: `ReadConfig`, `UserStore`
- Acronyms all caps: `HTTP`, `ID`, `URL`, `API` — `httpClient`, `userID`
- Package names: single lowercase word, no `_`, no `util`/`common`/`base`
- Getters without `Get` prefix: `user.Name()` not `user.GetName()`
- Interfaces: single-method interfaces end in `-er`: `Reader`, `Stringer`, `Handler`

## Error Handling

- Always check errors — never use `_` for error values
- Return errors, don't panic (panic only for truly unrecoverable states)
- Wrap errors with context: `fmt.Errorf("open config: %w", err)`
- Sentinel errors: `var ErrNotFound = errors.New("not found")`
- Custom errors for behavior: implement `Error() string` interface
- Check error types with `errors.Is` / `errors.As`, never `==`
- Handle errors first, happy path unindented:

```go
val, err := doSomething()
if err != nil {
    return fmt.Errorf("do something: %w", err)
}
// happy path continues
```

## Functions

- Accept interfaces, return concrete types
- Context as first param: `func Do(ctx context.Context, ...)`
- Options pattern for 3+ optional params:

```go
type Option func(*config)

func WithTimeout(d time.Duration) Option {
    return func(c *config) { c.timeout = d }
}

func New(opts ...Option) *Client {
    cfg := defaultConfig()
    for _, opt := range opts {
        opt(&cfg)
    }
    return &Client{cfg: cfg}
}
```

- Return early, avoid else:

```go
if err != nil {
    return err
}
// keep going
```

## Interfaces

- Keep small: 1-3 methods ideal
- Define at the consumer, not the producer
- Don't export interfaces for testing only — use unexported
- `io.Reader`, `io.Writer`, `fmt.Stringer` — compose from stdlib interfaces
- Empty interface `any` — avoid unless truly generic

## Structs

- Zero value should be useful: `var buf bytes.Buffer` works without init
- Constructor functions: `NewClient(...)` returns `*Client`
- Group fields logically, add blank lines between groups
- Embed for behavior reuse, not for type hierarchy

## Concurrency

- Share memory by communicating — channels over mutexes when logic is complex
- Mutexes for simple shared state protection
- Always handle goroutine lifecycle — no fire-and-forget:

```go
g, ctx := errgroup.WithContext(ctx)
g.Go(func() error {
    return doWork(ctx)
})
if err := g.Wait(); err != nil {
    return err
}
```

- Pass `context.Context` for cancellation
- `sync.Once` for lazy initialization
- `sync.WaitGroup` or `errgroup.Group` for fan-out
- Never start goroutines in `init()`

## Packages

- One package = one idea
- No circular imports — flatten or extract shared types
- `internal/` for packages not for external consumption
- `cmd/` for entry points:

```
project/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── handler/
│   ├── store/
│   └── model/
├── pkg/              # optional, public library code
├── go.mod
└── go.sum
```

- `main` package: parse flags/config, wire dependencies, run

## Testing

- Table-driven tests:

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name  string
        input string
        want  int
        err   bool
    }{
        {"valid", "42", 42, false},
        {"empty", "", 0, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.err {
                t.Fatalf("unexpected error: %v", err)
            }
            if got != tt.want {
                t.Errorf("Parse(%q) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

- `t.Fatal` for setup failures, `t.Error` for assertion failures
- `t.Helper()` in test helper functions
- `testdata/` directory for test fixtures
- `_test.go` suffix — test files are excluded from production builds
- Test package: `package foo_test` for black-box, `package foo` for internals
- `httptest.NewServer` for HTTP testing
- No assertion libraries needed — `if got != want` is enough

## Misc

- `defer` for cleanup — right after acquiring resource
- `context.Context` for cancellation, deadlines, request-scoped values — never store in structs
- Use `time.Duration`, not `int` for timeouts
- `log/slog` for structured logging (Go 1.21+)
- `errors.Join` for collecting multiple errors (Go 1.20+)
- Prefer stdlib over dependencies — `net/http`, `encoding/json`, `text/template`
- `go vet` and `staticcheck` in CI
