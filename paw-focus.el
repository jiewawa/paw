;;; paw-focus.el -*- lexical-binding: t; -*-

(require 'paw-vars)
(require 'paw-kagome)
(require 'paw-ecdict)
(require 'paw-note)
(require 'paw-org)
(require 'paw-svg)

(require 'focus)


(defun paw-focus-find-current-thing()
  (interactive)
  (cond ((get-char-property (point) 'paw-entry)
         (paw-view-note))
        (t (let* ((thing (or paw-note-word
                             (if mark-active
                                 (buffer-substring-no-properties (region-beginning) (region-end))
                               (if focus-mode
                                   (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds)))
                                 (paw-get-sentence-or-line))) ))
                  (lang_word (paw-remove-spaces-based-on-ascii-rate-return-cons thing))
                  (lang (car lang_word))
                  (new-thing (cdr lang_word)))
             (paw-view-note (paw-new-entry new-thing :lang lang))))))

(defun paw-focus-find-current-thing-with-mouse(event)
  (interactive "e")
  (let ((window (posn-window (event-end event)))
        (pos (posn-point (event-end event))))
    (if (not (windowp window))
        (error "No URL chosen"))
    (with-current-buffer (window-buffer window)
      (goto-char pos)
      (paw-focus-find-current-thing))))

(defun paw-focus-find-current-thing-segment-with-mouse(event)
  (interactive "e")
  (let ((window (posn-window (event-end event)))
        (pos (posn-point (event-end event))))
    (if (not (windowp window))
        (error "No URL chosen"))
    (with-current-buffer (window-buffer window)
      (goto-char pos)
      (paw-focus-find-current-thing-segment))))


(defun paw-focus-find-current-thing-segment(&optional thing)
  (interactive)
  (let* ((thing (or thing
                    paw-note-word
                    (if mark-active
                        (buffer-substring-no-properties (region-beginning) (region-end))
                      (if focus-mode
                          (let ((focus-thing (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds)))))
                            ;; remove org links
                            (when (string-match "\\[\\[.*?\\]\\[.*?\\]\\]" focus-thing)
                              (setq focus-thing (replace-match "" nil nil focus-thing)))
                            focus-thing)
                        (paw-get-sentence-or-line)))))
         (lang_word (paw-remove-spaces-based-on-ascii-rate-return-cons thing))
         (lang (car lang_word))
         (new-thing (cdr lang_word)))
    ;; ;; delete the overlay, focus mode does not not need click overlay
    ;; (if paw-click-overlay
    ;;     (delete-overlay paw-click-overlay) )
    ;; deactivate mark indicating it is processing
    (when mark-active
        (paw-click-show (region-beginning) (region-end) 'paw-focus-face)
        (deactivate-mark))
    ;; (format "Analysing %s..." new-thing)
    (cond ((string= lang "en")
           (paw-view-note (paw-new-entry new-thing :lang "en")
                          :no-pushp t ;; for better performance
                          :kagome (lambda(word _buffer) ;; FIXME buffer is not used
                                    (paw-ecdict-command word 'paw-focus-view-note-process-sentinel-english))))
          ((string= lang "ja")
           (paw-view-note (paw-new-entry new-thing :lang "ja")
                          :no-pushp t ;; for better performance
                          :kagome (lambda(word _buffer) ;; FIXME buffer is not used
                                    (paw-kagome-command word 'paw-focus-view-note-process-sentinel-japanese))))
          ;; fallbck to normal `paw-view-note'
          (t (paw-view-note (paw-new-entry new-thing :lang lang))))))


(defun paw-focus-find-unknown-words(&optional thing)
  (interactive)
  (let* ((thing (or thing
                    paw-note-word
                    (if mark-active
                        (buffer-substring-no-properties (region-beginning) (region-end))
                      (if focus-mode
                          (let ((focus-thing (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds)))))
                            ;; remove org links
                            (when (string-match "\\[\\[.*?\\]\\[.*?\\]\\]" focus-thing)
                              (setq focus-thing (replace-match "" nil nil focus-thing)))
                            focus-thing)
                        (buffer-string)))))
         (lang_word (paw-remove-spaces-based-on-ascii-rate-return-cons thing))
         (lang (car lang_word))
         (new-thing (cdr lang_word)))
    ;; delete the click overlay
    (if paw-click-overlay
        (delete-overlay paw-click-overlay) )
    ;; deactivate mark indicating it is processing
    (if mark-active
        (deactivate-mark))
    ;; (format "Analysing %s..." new-thing)
    (cond ((string= lang "en")
           (paw-ecdict-command new-thing 'paw-focus-find-unknown-words-sentinel-english))
          ((string= lang "ja")
           (paw-kagome-command new-thing 'paw-focus-view-note-process-sentinel-japanese))
          (t (message "Unsupported language %s" lang)))))

(defun paw-focus-find-next-thing-segment()
  (interactive)
  (call-interactively 'paw-focus-next-thing)
  (call-interactively  'paw-focus-find-current-thing-segment))

(defun paw-focus-next-thing (&optional n)
  "Move the point to the middle of the Nth next thing without `recenter.'"
  (interactive "p")
  (let ((current-bounds (focus-bounds))
        (thing (focus-get-thing)))
    (forward-thing thing n)
    (when (equal current-bounds (focus-bounds))
      (forward-thing thing (cl-signum n)))
    (let ((bounds (focus-bounds)))
      (when bounds
        (goto-char (/ (+ (car bounds) (cdr bounds)) 2))))))

(defun paw-focus-prev-thing (&optional n)
  "Move the point to the middle of the Nth previous thing."
  (interactive "p")
  (paw-focus-next-thing (- n)))

(defun paw-focus-find-prev-thing-segment()
  (interactive)
  (call-interactively 'paw-focus-prev-thing)
  (call-interactively  'paw-focus-find-current-thing-segment))



(defun paw-focus-find-current-thing-segment-japanese()
  (interactive)
  (if (get-char-property (point) 'paw-entry)
      (paw-view-note)
    (paw-kagome-command
     (if mark-active
         (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (region-beginning) (region-end)) )
       (if focus-mode
           (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds))) )
         (paw-remove-spaces-based-on-ascii-rate (thing-at-point 'sentence t) )))
     'paw-focus-view-note-process-sentinel-japanese) ))

(defun paw-focus-find-next-thing-segment-japanese()
  (interactive)
  (call-interactively 'focus-next-thing)
  (paw-kagome-command
   (if mark-active
       (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (region-beginning) (region-end)) )
     (if focus-mode
         (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds))) )
       (paw-remove-spaces-based-on-ascii-rate (thing-at-point 'sentence t) )))
   'paw-focus-view-note-process-sentinel-japanese))

(defun paw-focus-find-prev-thing-segment-japanese()
  (interactive)
  (call-interactively 'focus-prev-thing)
  (paw-kagome-command
   (if mark-active
       (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (region-beginning) (region-end)) )
     (if focus-mode
         (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds))) )
       (paw-remove-spaces-based-on-ascii-rate (thing-at-point 'sentence t) )))
   'paw-focus-view-note-process-sentinel-japanese))


(defun paw-focus-view-note-process-sentinel-japanese (proc _event)
  "Handles the Kagome process termination event."
  (when (eq (process-status proc) 'exit)
    (let* ((json-object-type 'plist)
           (json-array-type 'list)
           (buffer-content (with-current-buffer (process-buffer proc)
                             (buffer-string)))
           (json-responses (json-read-from-string buffer-content))
           (segmented-text (mapconcat
                            (lambda (resp) (plist-get resp :surface))
                            json-responses
                            " "))
           candidates)
      (with-current-buffer (get-buffer paw-view-note-buffer-name)
        (let ((buffer-read-only nil))
          (search-forward "** Meaning" nil t)
          (org-mark-subtree)
          (forward-line)
          (delete-region (region-beginning) (region-end))
          (dolist (resp json-responses candidates)
            (let* ((start (plist-get resp :start))
                   (end (plist-get resp :end))
                   (surface (plist-get resp :surface))
                   (cls (plist-get resp :class)) ;; 'class' is a built-in function
                   (pos (plist-get resp :pos))
                   (base-form (plist-get resp :base_form))
                   (reading (plist-get resp :reading))
                   (pronunciation (plist-get resp :pronunciation))
                   (features (plist-get resp :features))
                   (entry (paw-candidate-by-word surface))) ; features just a combination of other fields
              (when (string= cls "KNOWN")
                (insert (format "*** [[paw:%s][%s]] %s " surface surface pos))
                (insert (paw-play-button
                         (lambda ()
                           (interactive)
                           (funcall paw-default-say-word-function surface "ja"))) " ")
                (if entry
                    (progn
                      (insert (paw-edit-button
                               (lambda ()
                                 (interactive)
                                 (funcall 'paw-find-note (car (paw-candidate-by-word surface) )))) " ")
                      (insert (paw-delete-button
                               (lambda ()
                                 (interactive)
                                 (funcall 'paw-delete-word (car (paw-candidate-by-word surface) )))) " ")
                      )
                  (insert (paw-add-button
                           (lambda ()
                             (interactive)
                             (if paw-add-button-online-p
                                 (funcall-interactively 'paw-add-online-word surface segmented-text)
                               (funcall-interactively 'paw-add-offline-word surface segmented-text)))) " ")
                  )
                (insert (paw-goldendict-button (lambda ()
                                                 (interactive)
                                                 (funcall paw-external-dictionary-function surface))) "\n")
                ;; (insert "#+BEGIN_SRC\n")
                (insert (format "base_form: %s, reading: %s, pronunciation: %s\n"
                                base-form reading pronunciation) )
                ;; (insert "#+BEGIN_SRC sh\n"
                ;;         (shell-command-to-string (format "myougiden --human %s" surface))
                ;;         "#+END_SRC\n\n"

                ;;         )
                ;; (insert "#+END_SRC\n\n")
                )
              (if entry (push (car entry) candidates))))
          (paw-show-all-annotations candidates)
          (deactivate-mark)
          (goto-char (point-min))
          (unless (search-forward "** Dictionaries" nil t)
            (search-forward "** Translation" nil t))
          (beginning-of-line))
        )
      ;; TODO back to original window, but unsafe
      ;; (other-window 1)

      )))

(defun paw-focus-find-current-thing-segment-english()
  (interactive)
  (if (get-char-property (point) 'paw-entry)
      (paw-view-note)
    (paw-ecdict-command
     (if mark-active
         (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (region-beginning) (region-end)) )
       (if focus-mode
           (paw-remove-spaces-based-on-ascii-rate (buffer-substring-no-properties (car (focus-bounds)) (cdr (focus-bounds))) )
         (paw-remove-spaces-based-on-ascii-rate (thing-at-point 'sentence t) )))
     'paw-focus-view-note-process-sentinel-english) ))


(defun paw-focus-view-note-process-sentinel-english (proc _event)
  "Handles the english process termination event."
  (when (eq (process-status proc) 'exit)
    (let* ((json-object-type 'plist)
           (json-array-type 'list)
           (original-string (with-current-buffer (process-buffer proc)
                              original-string))
           (buffer-content (with-current-buffer (process-buffer proc)
                             (buffer-string)))
           (json-responses (json-parse-string buffer-content :object-type 'plist :array-type 'list))
           (segmented-text (mapconcat
                            (lambda (resp) (plist-get resp :word))
                            json-responses
                            " "))
           candidates)
      (with-current-buffer (get-buffer paw-view-note-buffer-name)
        (let ((buffer-read-only nil))
          (search-forward "** Meaning" nil t)
          (org-mark-subtree)
          (forward-line)
          (delete-region (region-beginning) (region-end))
          (insert (format "*** Total %s; tags:%s; oxford:%s; collins:%s; bnc:%s frq:%s;\n"
                          (length json-responses)
                          paw-ecdict-tags
                          (number-to-string paw-ecdict-oxford)
                          (number-to-string paw-ecdict-collins-max-level)
                          (number-to-string paw-ecdict-bnc)
                          (number-to-string paw-ecdict-frq)))
          (dolist (resp json-responses candidates)
            (let* ((id (plist-get resp :id))
                   (word (plist-get resp :word))
                   (sw (plist-get resp :sw))
                   (phonetic (plist-get resp :phonetic))
                   (definition (plist-get resp :definition))
                   (translation (plist-get resp :translation))
                   (pos (plist-get resp :pos))
                   (collins (plist-get resp :collins))
                   (oxford  (plist-get resp :oxford))
                   (tag (plist-get resp :tag))
                   (bnc (plist-get resp :bnc))
                   (frq (plist-get resp :frq))
                   (exchange (plist-get resp :exchange))
                   (detail (plist-get resp :detail))
                   (audio (plist-get resp :audio))
                   (entry (paw-candidate-by-word word))) ; features just a combination of other fields
              (when (and (not (string= word "nil")) (> (if frq frq 0) paw-ecdict-frq))
                (insert (format "*** [[paw:%s][%s]] [%s] " word word phonetic))
                (insert (paw-play-button
                         (lambda ()
                           (interactive)
                           (funcall paw-default-say-word-function word "en"))) " ")
                (if entry
                    (progn
                      (insert (paw-edit-button (lambda ()
                                                 (interactive)
                                                 (funcall 'paw-find-note (car (paw-candidate-by-word word) )))) " ")
                      (insert (paw-delete-button (lambda ()
                                                   (interactive)
                                                   (funcall 'paw-delete-word (car (paw-candidate-by-word word) )))) " "))
                  (insert (paw-add-button (lambda ()
                                            (interactive)
                                            (if paw-add-button-online-p
                                                (funcall-interactively 'paw-add-online-word word original-string)
                                              (funcall-interactively 'paw-add-offline-word word original-string) ))) " "))
                (insert (paw-goldendict-button (lambda ()
                                                 (interactive)
                                                 (funcall paw-external-dictionary-function word))) "\n")

                (paw-insert-and-make-overlay
                 (format "_collins_: %s, _oxford_: %s, _tag_: %s, _bnc_ %s, _frq_: %s, _exchange_: %s\n%s\n%s\n"
                                collins oxford tag bnc frq exchange translation definition )
                 'face 'org-block)
                (if entry (push (car entry) candidates) ))))
          ;; (paw-show-all-annotations candidates)
          (deactivate-mark)
          (goto-char (point-min))
          (unless (search-forward "** Dictionaries" nil t)
            (search-forward "** Translation" nil t))
          (beginning-of-line)))
      ;; TODO back to original window, but unsafe
      ;; (other-window 1)

      )))


(defun paw-focus-find-unknown-words-sentinel-english (proc _event)
  "Handles the english process termination event."
  (when (eq (process-status proc) 'exit)
    (let* ((json-object-type 'plist)
           (json-array-type 'list)
           (original-string (with-current-buffer (process-buffer proc)
                              original-string))
           (buffer-content (with-current-buffer (process-buffer proc)
                             (buffer-string)))
           (json-responses (json-parse-string buffer-content :object-type 'plist :array-type 'list))
           candidates
           order)
      (setq order 1)
      (dolist (resp json-responses candidates)
        (setq order (+ order 1))
        (let* ((word (plist-get resp :word))
               entry
               ;; (entry (paw-candidate-by-word word)) ;; check in db, if KNOWN words, would not push
               ) ; features just a combination of other fields

          ;; skip the similar word in db
          ;; FIXME: this could be done in python as well
          (unless (paw-check-word-exist-p word)
            (push (paw-new-entry word :lang "en"
                                 ;; FIXME: use created-at to store the order,
                                 ;; because new words are not in db, can not
                                 ;; compare the time with the words in db
                                 :created-at (format-time-string "%Y-%m-%d %H:%M:%S" (time-add (current-time) (seconds-to-time order)))
                                 :add-to-known-words t ;; so that it could be added into default known file
                                 ) candidates) )))
      (with-current-buffer (current-buffer)
        (paw-show-all-annotations candidates))

      )))


(provide 'paw-focus)
