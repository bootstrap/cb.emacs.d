;;; glab.el --- minuscule client library for the Gitlab API  -*- lexical-binding: t -*-

;; Copyright (C) 2016-2018  Jonas Bernoulli

;; Author: Jonas Bernoulli <jonas@bernoul.li>
;; Homepage: https://github.com/magit/ghub
;; Keywords: tools
;; Package-Requires: ((emacs "24.4") (ghub "2.0"))

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a copy of the GPL see https://www.gnu.org/licenses/gpl.txt.

;;; Commentary:

;; Ghub is a library that provides basic support for using the Github API
;; from Emacs packages.  It abstracts access to API resources using only
;; a handful of functions that are not resource-specific.

;; This library is implemented on top of Ghub.  Unlike Ghub, Glab does
;; not support the guided creation of tokens because Gitlab lacks the
;; features that would be necessary to implement that.  Users have to
;; create tokens through the web interface.

;;; Code:

(require 'ghub)

(defconst glab-default-host "gitlab.com/api/v4")

(cl-defun glab-head (resource &optional params
                              &key query payload headers
                              unpaginate noerror reader
                              username auth host)
  "Make a `HEAD' request for RESOURCE, with optional query PARAMS.
Like calling `ghub-request' (which see) with \"HEAD\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "HEAD" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-get (resource &optional params
                             &key query payload headers
                             unpaginate noerror reader
                             username auth host)
  "Make a `GET' request for RESOURCE, with optional query PARAMS.
Like calling `ghub-request' (which see) with \"GET\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "GET" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-put (resource &optional params
                             &key query payload headers
                             unpaginate noerror reader
                             username auth host)
  "Make a `PUT' request for RESOURCE, with optional payload PARAMS.
Like calling `ghub-request' (which see) with \"PUT\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "PUT" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-post (resource &optional params
                              &key query payload headers
                              unpaginate noerror reader
                              username auth host)
  "Make a `POST' request for RESOURCE, with optional payload PARAMS.
Like calling `ghub-request' (which see) with \"POST\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "POST" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-patch (resource &optional params
                               &key query payload headers
                               unpaginate noerror reader
                               username auth host)
  "Make a `PATCH' request for RESOURCE, with optional payload PARAMS.
Like calling `ghub-request' (which see) with \"PATCH\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "PATCH" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-delete (resource &optional params
                                &key query payload headers
                                unpaginate noerror reader
                                username auth host)
  "Make a `DELETE' request for RESOURCE, with optional payload PARAMS.
Like calling `ghub-request' (which see) with \"DELETE\" as METHOD
and `gitlab' as FORGE."
  (ghub-request "DELETE" resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

(cl-defun glab-request (method resource &optional params
                               &key query payload headers
                               unpaginate noerror reader
                               username auth host)
  "Make a request for RESOURCE and return the response body.
Like calling `ghub-request' (which see) with `gitlab' as FORGE."
  (ghub-request method resource params :forge 'gitlab
                :query query :payload payload :headers headers
                :unpaginate unpaginate :noerror noerror :reader reader
                :username username :auth auth :host host))

;;; glab.el ends soon
(provide 'glab)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; glab.el ends here
