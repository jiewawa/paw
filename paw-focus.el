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
             (cond ((string= lang "en") (paw-view-note (paw-new-entry new-thing)))
                   ((string= lang "ja") (paw-view-note (paw-new-entry new-thing))))))))

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
    (message "Analysing %s..." new-thing)
    (cond ((string= lang "en") (paw-ecdict-command new-thing
                                               'paw-focus-view-note-process-sentinel-english))
          ((string= lang "ja") (paw-kagome-command new-thing 'paw-focus-view-note-process-sentinel-japanese))
          (t (paw-view-note (paw-new-entry new-thing nil lang))))))

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
           candidates
           (kagome-output (with-temp-buffer
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
                                                              (funcall paw-read-function-2 surface))) " ")
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
                                                                  (funcall-interactively 'paw-add-online-word surface segmented-text))) " ")
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
                                (if entry (push (car entry) candidates) )))
                            (buffer-string)) ))
      (paw-view-note (paw-new-entry segmented-text kagome-output "ja") nil)
      (with-current-buffer (get-buffer paw-view-note-buffer-name)
        (paw-show-all-annotations candidates)
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
           (json-responses (json-read-from-string buffer-content))
           (segmented-text (mapconcat
                            (lambda (resp) (plist-get resp :word))
                            json-responses
                            " "))
           candidates
           (kagome-output (with-temp-buffer
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
                                (when (and (not (string= word "nil")) (> frq paw-ecdict-frq) )
                                    (insert (format "*** [[paw:%s][%s]] [%s] " word word phonetic))
                                    (insert (paw-play-button
                                                            (lambda ()
                                                              (interactive)
                                                              (funcall paw-read-function-2 word))) " ")
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
                                                                 (funcall-interactively 'paw-add-online-word word original-string))) " "))
                                    (insert (paw-goldendict-button (lambda ()
                                                                   (interactive)
                                                                   (funcall paw-external-dictionary-function word))) "\n")

                                    ;; (insert "#+BEGIN_SRC\n")
                                    (insert (format "_collins_: %s, _oxford_: %s, _tag_: %s, _bnc_ %s, _frq_: %s, _exchange_: %s\n%s\n%s\n"
                                                    collins oxford tag bnc frq exchange translation definition ))
                                    ;; (insert "#+END_SRC\n")
                                    (if entry (push (car entry) candidates) ))))
                            (buffer-string)) ))
      (paw-view-note (paw-new-entry original-string kagome-output "en") nil)
      (with-current-buffer (get-buffer paw-view-note-buffer-name)
        (paw-show-all-annotations candidates))
      ;; TODO back to original window, but unsafe
      ;; (other-window 1)

      )))

(provide 'paw-focus)
