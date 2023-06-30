(define-module (guix)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git)
  #:use-module (guix git-download)
  #:use-module (guix build-system dune)
  #:use-module (guix build-system ocaml)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages license)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mp3)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ocaml)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rdf)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages zig))

(define-public ocaml-thread-table
  (package
    (name "ocaml-thread-table")
    (version "0.1.0")
    (source (origin
              (method url-fetch)
              (uri
               "https://github.com/ocaml-multicore/thread-table/releases/download/0.1.0/thread-table-0.1.0.tbz")
              (sha256
               (base32
                "0ywdjnyjpryfs2szvlm4mdvvcmq34q66jbh64rbfgrjn5z003kkp"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-odoc))
    (native-inputs (list ocaml-mdx ocaml-alcotest))
    (home-page "https://github.com/ocaml-multicore/thread-table")
    (synopsis "A lock-free thread-safe integer keyed hash table")
    (description #f)
    (license license:bsd-0)))

(define-public ocaml-domain-local-await
  (package
    (name "ocaml-domain-local-await")
    (version "0.2.1")
    (source (origin
              (method url-fetch)
              (uri
               "https://github.com/ocaml-multicore/domain-local-await/releases/download/0.2.1/domain-local-await-0.2.1.tbz")
              (sha256
               (base32
                "0viflr2252lcbdxk40sk4pqg1h8plqb5qim7v774kx34ba2nq31d"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ; TODO
    (propagated-inputs (list ocaml-thread-table ocaml-odoc))
    (native-inputs (list ocaml-alcotest ocaml-mdx))
    (home-page "https://github.com/ocaml-multicore/domain-local-await")
    (synopsis "A scheduler independent blocking mechanism")
    (description #f)
    (license license:bsd-0)))

(define ocaml-eio
  (package
    (name "ocaml-eio")
    (version "0.10")
    (home-page "https://github.com/ocaml-multicore/eio")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256 (base32
                "1dkbzdz6b6486pcnzwmisibgz2jr1mz15072yc8cfig0gxxh4y7p"))))
    (build-system dune-build-system)
    (arguments `(#:package "eio"))
    (propagated-inputs (list ocaml-bigstringaf
                             ocaml-cstruct
                             ocaml-lwt
                             ocaml-lwt-dllist
                             ocaml-logs
                             ocaml-optint
                             ocaml-psq
                             ocaml-fmt
                             ocaml-hmap
			     ocaml-domain-local-await
                             ocaml-mtime
                             ocaml-odoc))
    (native-inputs (list ocaml-astring
                         ocaml-crowbar
                         ocaml-alcotest
                         ocaml-mdx))
    (synopsis "Effect-based direct-style IO API for OCaml")
    (description "This package provides an effect-based IO API for multicore
OCaml with fibers.")
    (license license:isc)))

(define-public ocaml5.0-eio
  (package-with-ocaml5.0 ocaml-eio))

(define ocaml-eio-linux
  (package
    (inherit ocaml-eio)
    (name "ocaml-eio-linux")
    (arguments `(#:package "eio_linux"
		 ;; TODO
		 #:tests? #f))
    (propagated-inputs
     (list ocaml-eio
           ocaml-uring
           ocaml-logs
           ocaml-fmt))
    (native-inputs
     (list ocaml-mdx
           ocaml-alcotest
           ocaml-mdx))
    (synopsis "Linux backend for ocaml-eio")
    (description "@code{Eio_linux} provides a Linux io-uring backend for
@code{Ocaml Eio} APIs, plus a low-level API that can be used directly
(in non-portable code).")))

(define-public ocaml5.0-eio-linux
  (package-with-ocaml5.0 ocaml-eio-linux))

(define ocaml-eio-main
  (package
    (inherit ocaml-eio)
    (name "ocaml-eio-main")
    (arguments `(#:package "eio_main"
                 ;; tests require network
                 #:tests? #f))
    (propagated-inputs
     (list ocaml-eio
           ocaml-eio-linux))
    (native-inputs
     (list ocaml-mdx))
    (synopsis "Eio backend selector")
    (description "@code{Eio_main} selects an appropriate backend (e.g.
@samp{eio_linux} or @samp{eio_luv}), depending on your platform.")))

(define-public ocaml5.0-eio-main
  (package-with-ocaml5.0 ocaml-eio-main))

(define-public ocaml5.0-coap
  (let ((commit "d86c4242bb49cc8f45e1dcfaeddb44190e7ad691")
	(revision "0"))
    (package-with-ocaml5.0
     (package
       (name "ocaml-coap")
       (version "0.0.0")
       (home-page "https://github.com/adatario/ocaml-coap")
       (source
	(origin
	  (method git-fetch)
	  (uri (git-reference
		(url "https://github.com/adatario/ocaml-coap")
		(commit commit)))
	  (file-name (git-file-name name version))
	  (sha256
	   (base32
	    "0qji836b48d0lj78j3dmhy3rmbq9vlfzvx4aww96cc234lz9hl2c"))))
       (build-system dune-build-system)
       (propagated-inputs
	(list ocaml5.0-eio
	      ocaml5.0-eio-main
	      libuv))
       (native-inputs
	(list ocaml-alcotest
	      ocaml-qcheck))
       (synopsis "OCaml implementation of the Constrained Application
Protocol (CoAP - RFC 7252)")
       (description #f)
       (license license:isc)))))

(define-public ocaml-http
  (let ((commit "178a8736fdceef44278f1c71199fa7aacc0194a8")
	(revision "2"))
    (package
     (name "ocaml-http")
     (version (git-version "6.0.0-alpha" revision commit))
     (source (git-checkout (url (string-append (dirname (current-filename))
					       "/../ocaml-cohttp/"))))
     ;; (source

     ;;  (origin
     ;;   (method git-fetch)
     ;;   (uri (git-reference
     ;; 	     (url "https://github.com/mefyl/ocaml-cohttp")
     ;; 	     (commit commit)))
     ;;   (file-name (git-file-name name version))
     ;;   (sha256
     ;; 	(base32
     ;; 	 "09q48nv5rfy5bhvfcc4prdim9gvffz4x98gzxfs9w4hgy5xysyvp"))))
     (build-system dune-build-system)
     (arguments `(#:package "http"
		  ;; requires cohttp-eio
		  #:tests? #f))
     (native-inputs
      (list ocaml-ppx-expect
	    ocaml-alcotest
	    ocaml-base-quickcheck
	    ocaml-ppx-assert
	    ocaml-ppx-sexp-conv
	    ocaml-ppx-compare
	    ocaml-ppx-here
	    ocaml-core
	    ocaml-crowbar
	    ocaml-sexplib0))
     (home-page "https://github.com/mirage/ocaml-cohttp")
     (synopsis "OCaml type definitions of HTTP essentials")
     (description
      "This OCaml package contains essential type definitions used in
@var{ocaml-cohttp}.  It is designed to have no dependencies and make
it easy for other packages to easily interoperate with @var{ocaml-cohttp}.")
     (license license:isc))))

(define-public ocaml-ptime
  (package
  (name "ocaml-ptime")
  (version "1.1.0")
  (source
    (origin
      (method url-fetch)
      (uri
       (string-append
	"https://erratique.ch/software/ptime/releases/ptime-"
	version ".tbz"))
      (sha256
        (base32
          "1c9y07vnvllfprf0z1vqf6fr73qxw7hj6h1k5ig109zvaiab3xfb"))))
  (build-system ocaml-build-system)
  (arguments
   `(#:build-flags (list "build" "--tests" "true")
     #:phases
     (modify-phases %standard-phases
       (delete 'configure))))
  (native-inputs
   (list ocaml-findlib
	 ocamlbuild
	 ocaml-topkg
	 opam))
  (home-page "https://erratique.ch/software/ptime")
  (synopsis "POSIX time for OCaml")
  (description
    "Ptime offers platform independent POSIX time support in pure OCaml. It
provides a type to represent a well-defined range of POSIX timestamps
with picosecond precision, conversion with date-time values,
conversion with [RFC 3339 timestamps][rfc3339] and pretty printing to a
human-readable, locale-independent representation.")
  (license license:isc)))

(define-public ocaml-cohttp
  (package
   (inherit ocaml-http)
   (name "ocaml-cohttp")
   (arguments `(#:package "cohttp"
		#:tests? #f))
   (propagated-inputs
    (list ocaml-base64
	  ocaml-logs
	  ocaml-re
	  ocaml-sexplib0
	  ocaml-stringext
	  ocaml-uri
	  ocaml-uri-sexp
	  ocaml-http))
   (native-inputs
    (list ocaml-alcotest
	  ocaml-fmt))
   (synopsis "OCaml CoHTTP implementation with eio backend")
   (description "An OCaml CoHTTP server and client implementation based on the @var{ocaml-eio} library.  @var{ocaml-cohttp-eio} features a multicore capable HTTP 1.1 server.  The library promotes and is built with direct style of coding as opposed to a monadic.")))

(define-public ocaml-cohttp-eio
  (package
   (inherit ocaml-http)
   (name "ocaml-cohttp-eio")
   (arguments `(#:package "cohttp-eio"
		#:tests? #f))
   (propagated-inputs
    (list ocaml5.0-eio
	  ocaml-fmt
	  ocaml-ptime
	  ocaml-http
	  ocaml-cohttp))
   (native-inputs
    (list ocaml5.0-eio-main
	  ocaml-mdx
	  ocaml-uri
	  ocaml-ppx-expect
	  ocaml-ppx-inline-test))
   (synopsis "OCaml CoHTTP implementation with eio backend")
   (description "An OCaml CoHTTP server and client implementation based on the @var{ocaml-eio} library.  @var{ocaml-cohttp-eio} features a multicore capable HTTP 1.1 server.  The library promotes and is built with direct style of coding as opposed to a monadic.")))

(define-public ocaml-ipaddr-cstruct
  (package
    (inherit ocaml-macaddr)
    (name "ocaml-ipaddr-cstruct")
    (arguments `(#:package "ipaddr-cstruct"))
    (propagated-inputs
     (list ocaml-ipaddr
	   ocaml-cstruct))
    (synopsis "OCaml library for manipulation of IP addresses as C-like structres")
    (description "This OCaml library provides functions for manipulating as
C-like structures using the @code{ocaml-cstruct} library.")))

(define-public ocaml-ipaddr-sexp
  (package
    (inherit ocaml-macaddr)
    (name "ocaml-ipaddr-sexp")
    (arguments `(#:package "ipaddr-sexp"))
    (propagated-inputs
     (list ocaml-ipaddr
	   ocaml-ppx-sexp-conv
	   ocaml-sexplib0))
    (native-inputs
     (list ocaml-ipaddr-cstruct
	   ocaml-ounit))
    (synopsis "OCaml library for manipulation of IP addresses as S-expressions")
    (description "This OCaml library provides functions for manipulating as
S-expressions using the @code{ocaml-sexp} library.")))

(define-public ocaml-conduit
  (package
    (name "ocaml-conduit")
    (version "6.0.1")
    (home-page "https://github.com/mirage/ocaml-conduit")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1p46f8k9q3fl4vf00ln4yj0lhf2xp6zl23jyi5bzdaf4mrc6wvch"))))
    (build-system dune-build-system)
    (arguments `(#:package "conduit"))
    (propagated-inputs
     (list ocaml-ppx-sexp-conv
	   ocaml-sexplib
	   ocaml-astring
	   ocaml-uri
	   ocaml-logs
	   ocaml-ipaddr
	   ocaml-ipaddr-sexp))
    (synopsis "OCaml library for establishing TCP and SSL/TLS connections")
    (description "This OCaml library provides an abstraction for establishing
TCP and SSL/TLS connections.  This allows using the same type signatures
regardless of the SSL library or platform being used.")
    (license license:isc)))

(define-public ocaml-websocket
  (package
   (name "ocaml-websocket")
   (version "2.16")
   (source (origin
            (method url-fetch)
            (uri
             "https://github.com/vbmithr/ocaml-websocket/releases/download/2.16/websocket-2.16.tbz")
            (sha256
             (base32
              "1sy5gp40l476qmbn6d8cfw61pkg8b7pg1hrbsvdq9n6s7mlg888j"))))
   (build-system dune-build-system)
   (arguments `(#:package "websocket"))
   (propagated-inputs (list ocaml-base64
                            ocaml-conduit
                            ocaml-cohttp
                            ocaml-ocplib-endian
                            ocaml-astring
                            ocaml-odoc))
   (home-page "https://github.com/vbmithr/ocaml-websocket")
   (synopsis "Websocket library")
   (description
    "The WebSocket Protocol enables two-way communication between a client running
untrusted code in a controlled environment to a remote host that has opted-in to
communications from that code.  The security model used for this is the
origin-based security model commonly used by web browsers.  The protocol
consists of an opening handshake followed by basic message framing, layered over
TCP. The goal of this technology is to provide a mechanism for browser-based
applications that need two-way communication with servers that does not rely on
opening multiple HTTP connections (e.g., using XMLHttpRequest or <iframe>s and
long polling).")
   (license license:isc)))

(package-with-ocaml5.0
 (package
  (name "eio-ws")
  (version "0.0.0")
  (source (git-checkout (url (dirname (current-filename)))))
  (build-system dune-build-system)
  (propagated-inputs
   (list ocaml-cohttp-eio
	 ocaml-websocket
	 ocaml5.0-eio-main))
  (native-inputs
   (list
    ;; dev tools
    reuse
    ocaml-merlin
    ocaml-dot-merlin-reader))
  (home-page "https://github.com/adatario/eio-ws")
  (synopsis #f)
  (description #f)
  (license #f)))

