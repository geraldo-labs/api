package app

// Server ...
type Server struct {
	Port int `json:"port" yaml:"port"`
}

// Endpoint ...
type Endpoint struct {
	Name string `json:"name" yaml:"name"`
	Path string `json:"path" yaml:"path"`
}
