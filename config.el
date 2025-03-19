;;; config.el -*- lexical-binding: t; -*-

(use-package paw
  :hook
  ;; my personal configs
  (paw-view-note-mode . paw-view-note-setup)
  (paw-annotation-mode . paw-annotation-setup)
  :init
  (setq paw-db-file (expand-file-name "paw.sqlite" org-directory))
  ;; ecdict dictionary
  (setq paw-ecdict-db (expand-file-name "stardict.db" org-directory))
  ;; setup ECDICT before using it, and create the files manually if not exist
  (setq paw-ecdict-wordlist-files `(
                                    ;; ,(expand-file-name "美国当代英语语料库.csv" org-directory) ;; https://www.eapfoundation.com/vocab/academic/other/mawl/
                                    ,(expand-file-name "mawl.csv" org-directory) ;; https://www.eapfoundation.com/vocab/academic/other/mawl/
                                    ,(expand-file-name "opal.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "5000.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "极品GRE红宝书.csv" org-directory)
                                    ,(expand-file-name "gre.txt" org-directory)
                                    ,(expand-file-name "托福绿宝书.csv" org-directory)
                                    ,(expand-file-name "2021_Teachers_AcademicCollocationList.csv" org-directory) ;; https://www.pearsonpte.com/teachers/academic-collocation
                                    ,(expand-file-name "The Unofficial Harry Potter Vocabulary Builder.csv" org-directory)
                                    ,(expand-file-name "Illustrated Everyday Expressions with Stories.csv" org-directory)
                                    ,(expand-file-name "Essential Idioms in English.csv" org-directory)
                                    ,(expand-file-name "IELTS_word_lists.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "Cambridge_word_lists_-_Advanced.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "Cambridge_word_lists_-_Intermediate.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "Cambridge_word_lists_-_Beginner.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "idioms.txt" org-directory)
                                    ,(expand-file-name "phrase-list.csv" org-directory) ;; https://www.oxfordlearnersdictionaries.com/wordlists/
                                    ,(expand-file-name "英语生词本.csv" org-directory)
                                    ))
  ;; setup ECDICT before using it, and create the files manually if not exist
  (setq paw-ecdict-known-words-files `(,(expand-file-name "eudic.csv" org-directory)
                                       ,(expand-file-name "english.txt" org-directory)))
  ;; setup ECDICT before using it, and create the file manually if not exists
  (setq paw-ecdict-default-known-words-file (expand-file-name "english.txt" org-directory))

  ;; jlpt dictionary
  (setq paw-jlpt-db (expand-file-name "japanese.db" org-directory))
  ;; setup jlpt before using it, and create the files manually if not exist
  (setq paw-jlpt-wordlist-files `(;,(expand-file-name "日语生词本.csv" org-directory)
                                        ;,(expand-file-name "日本语红宝书.csv" org-directory)
                                  ;; ,(expand-file-name "蓝宝书日语文法.csv" org-directory)
                                        ,(expand-file-name "NEW-JLPT.csv" org-directory)
                                  ))
  ;; setup jlpt before using it, and create the files manually if not exist
  (setq paw-jlpt-known-words-files `(,(expand-file-name "japanese.txt" org-directory)))
  ;; setup jlpt before using it, and create the file manually if not exists
  (setq paw-jlpt-default-known-words-file (expand-file-name "japanese.txt" org-directory))
  :custom
  ;; (paw-svg-enable t)
  ;; Use pbm buttons on android
  (paw-pbm-enable (if (eq system-type 'android) t))
  ;; Use all the icons icon on dashboard
  (paw-all-the-icons-icon-enable nil)
  ;; Use nerd icon on dashboard
  (paw-nerd-icons-icon-enable t)
  ;; Use all the icons button on non-android system
  (paw-all-the-icons-button-enable nil)
  ;; you can use (face-attribute 'org-block :background) or other color
  (paw-view-note-background-color 'unspecified)
  (paw-detect-language-p t)
  (paw-python-program (if (string-equal system-type "android") "python3.10" "python3"))
  (paw-detect-language-program
   (pcase system-type
     ('gnu/linux 'gcld3)
     ('windows-nt 'gcld3)
     ('darwin 'lingua)
     ('android 'gcld3)))
  (paw-click-overlay-enable t)
  (paw-annotation-read-only-enable t)
  (paw-annotation-show-wordlists-words-p t) ;; setup ECDICT before using it
  (paw-annotation-show-unknown-words-p nil) ;; setup ECDICT before using it
  (paw-ecdict-frq 3000) ;; all possible words, 0 no frq data
  (paw-ecdict-bnc -1) ;; all possible words, 0 no bnc data
  (paw-ecdict-tags "cet4 cet6 ielts toefl gre empty") ;; no easy words
  (paw-ecdict-oxford 0) ;; no easy words
  (paw-ecdict-collins-max-level 3) ;; no easy words
  ;; (paw-posframe-p (if (string-equal system-type "android") t))
  ;; For online words, you have to apply api on
  ;; https://my.eudic.net/OpenAPI/Authorization
  (paw-authorization-keys (auth-source-pick-first-password :host "eudic-api-key"))
  ;; limit the other languages web buttons number
  (paw-english-web-button-number (if (eq system-type 'android) 4 4))
  ;; limit the japanese web buttons number
  (paw-japanese-web-button-number (if (eq system-type 'android) 3 4))
  ;; limit the general web buttons number
  (paw-general-web-button-number (if (eq system-type 'android) 2 3))
  ;; (paw-default-say-word-function (if (eq system-type 'android) 'paw-android-say-word 'paw-say-word))
  (paw-tts-zh-cn-voice "zh-CN-YunjianNeural") ; zh-CN-XiaoxiaoNeural, zh-CN-YunyangNeural
  ;; (paw-sdcv-dictionary-list '("简明英汉字典增强版"))
  ;; add online word by default for add button
  (paw-add-button-online-p t)
  ;; show the note both in minibuffer or/and *paw-view-note*
  ;; To use this, you need to setup ECDICT (English) or JLPT (Japanese) before
  ;; use this, otherwise, use the 'buffer instead
  (paw-view-note-show-type
   (pcase system-type
     ('gnu/linux 'buffer)
     ('windows-nt 'buffer)
     ('darwin 'buffer)
     ('android 'buffer)))
  ;; must be one of the studylist name in `paw-studylist', please run `paw-get-all-studylist' to get the available studylists.
  (paw-default-online-studylist "ID: 133584289117482484, Language: en, Name: Business")
  ;; (paw-default-online-studylist "ID: 133616431737936696, Language: en, Name: 00 Japanese Mini Stories")
  (paw-offline-studylist '(("English Studylist" ;; studylist name when choosing offline studylist
                            (id . "1") ;; random id for internal use, but it could not be the same as any id in online study list defined in `paw-studylist'
                            (language . "en") ;; language of the studylist
                            (name . "English")) ;; name of the studylist
                           ("Japanese Studylist"
                            (id . "2")
                            (language . "ja")
                            (name . "Japanese"))))
  ;; must be one of the studylist name in `paw-offline-studylist'
  (paw-default-offline-studylist "English Studylist")
  (paw-search-page-max-rows (pcase system-type
                              ('gnu/linux 31)
                              ('windows-nt 31)
                              ('darwin 31)
                              ('android 31)))
  (paw-add-offline-word-without-asking t)
  (paw-add-online-word-without-asking t)
  ;; Servers to add online words. It could be eudic, anki, or both.
  (paw-online-word-servers (if (eq system-type 'android) '(eudic) '(eudic)))
  ;; (paw-translate-p (if (eq system-type 'android) nil t))
  ;; (paw-ask-ai-p (if (eq system-type 'android) nil t))
  ;; (paw-ai-translate-p (if (eq system-type 'android) nil t))
  ;; (paw-ai-translate-context-p (if (eq system-type 'android) nil t))
  ;; The default Anki deck to use.
  (paw-anki-deck "English")
  (paw-eudic-android-program
   (if (eq system-type 'android)
       (pcase android-model
         ("2407FPN8ER" "cn.jimex.dict")
         (_ "com.eusoft.eudic"))))
  (paw-yomitan-firefox-id (pcase system-type
                            ('gnu/linux "96f6234a-6ab3-44bd-959e-6f210a7c1bce")
                            ('darwin "564ae45f-377d-49a9-9100-8984720fcb7e")
                            ('android "95ec2c76-bb2c-4ef9-b5b9-d2ece354ae7b")))
  ;; I prefer to disable the One-Click to view note on PC, but enable it on mobile
  (paw-view-note-click-enable (pcase system-type
                                ('gnu/linux nil)
                                ('darwin nil)
                                ('android t)))
  :config
  (setq paw-note-dir (expand-file-name "paw" org-directory))
  ;; if the file was moved to other places after adding annotations, we can add
  ;; the parent path of the file for paw to search. This is necessary for
  ;; multiple clients (PC/Mobile/Pad) to use the same database but file location
  ;; is different.
  (setq paw-annotation-search-paths '("~/Data/Books/"
                                      "/storage/emulated/0/Books/"
                                      "/storage/0A079E23746DE025/Books/"
                                      "/storage/emulated/0/books/"
                                      "/storage/emulated/0/Download/"
                                      "/storage/emulated/0/Download/Telegram/"
                                      "/storage/emulated/0/org/web/"
                                      "~/org/web/"
                                      "~/Books/"
                                      "~/.telega/cache/documents"
                                      "~/Downloads/Telegram Desktop/"))

  ;; show image annotation in *paw-view-note*
  (add-hook 'paw-view-note-after-render-hook #'org-display-inline-images)
  (add-hook 'context-menu-functions #'paw-annotation-context-menu)

  (unless (string-equal system-type "android")
    (let ((func (cond
                 ((fboundp 'eaf-open-browser-other-window)
                  'eaf-open-browser-other-window)
                 (t 'browse-url))))
      (setq paw-dictionary-browse-function func)
      (setq paw-mdict-dictionary-function func)))

  ;; sdcv related configs
  (cond ((eq system-type 'darwin)
         (setq paw-sdcv-program "/opt/homebrew/bin/sdcv" )
         (setq paw-sdcv-dictionary-data-dir (expand-file-name "dict" doom-private-dir)))
        ((eq system-type 'windows-nt)
         (setq paw-sdcv-program (expand-file-name "~/.doom.d/modules/sdcv/sdcv.exe"))
         (setq paw-sdcv-dictionary-data-dir (expand-file-name "dict" doom-private-dir)))
        ((eq system-type 'gnu/linux)
         (setq paw-sdcv-env-lang (getenv "LANG"))
         (setq paw-sdcv-dictionary-data-dir (expand-file-name "dict" doom-private-dir)))
        ((string-equal system-type "android")
         (setq paw-sdcv-env-lang (getenv "LANG"))
         (setq paw-sdcv-dictionary-data-dir (expand-file-name ".doom.d/dict" termux-home-dir))))
  (setq paw-sdcv-dictionary-list    ;setup dictionary list for simple search
        '(
          "懒虫简明英汉词典"
          "Collins Cobuild English Dictionary"
          "小学馆-日中词典"
          "日汉双解词典"
          "EJ-EDict" "JE-EDICT_Kanji"
          "日汉词典" "jmdict-ja-en" "KANJIDIC2" "新明解国語辞典"
          "小学館中日辞典EB版" "広辞苑　第六版" "EJ-GENE95"
          "jmdict-en-ja"
          "JCEDict" "EDICT"
          ;; "Engligh Idioms (eng-eng)"
          "JEDict" "ENAMDICT" "EJDic" "DrEye日汉词典" "DrEye4in1词典"
          ;; "Longman Language Activator 2nd Ed. (En-En)"
          ;; "简明英汉字典增强版"
          ;; "Cambridge Advanced Learners Dictionary 3th Ed. (En-En)"
          ;; "新世纪汉英科技大词典" "Longman Dictionary of Contemporary English" "Merriam-Webster's Collegiate 11th Ed. (En-En)" "Longman Dictionary of Common Errors (En-En)" "WordNet" "牛津现代英汉双解词典" "新世纪英汉科技大词典" "Merriam-Webster's Collegiate Thesaurus (En-En)"
          ;; "21世纪双语科技词典" "KDic11万英汉词典"
          ;; "Collins Cobuild English Dictionary" "Longman Dictionary of Contemporary English 5th Ed. (En-En)"
          ;; "Merriam-Webster's Advanced Learner's Dictionary (En-En)"
          )))

(defun paw-view-note-setup ()

  (when (fboundp 'visual-line-mode)
    (visual-line-mode))

  (when (fboundp 'org-modern-mode)
    (org-modern-mode))

  (when (fboundp 'pangu-spacing-mode)
    (pangu-spacing-mode))

  (when (bound-and-true-p hl-line-mode)
    (hl-line-mode -1)))

(defun paw-annotation-setup()
  ;; TODO need manual enable later
  (when (bound-and-true-p flyspell-mode)
    (flyspell-mode -1)))
