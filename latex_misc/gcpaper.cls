\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{gcpaper}[2016/03/21 Basic paper class, version 0.0.0]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

\RequirePackage{amsmath}
\RequirePackage{amsthm}
\RequirePackage{mathtools}
\RequirePackage[T1]{fontenc}
\RequirePackage{lucidabr}
\RequirePackage[margin=1in]{geometry}
\RequirePackage[letterspace=35]{microtype}
\RequirePackage{bashful}
\RequirePackage{hyperref}
\RequirePackage{url}
\RequirePackage{ragged2e}
\RequirePackage{booktabs}
\RequirePackage{fancyhdr}
\RequirePackage{sectsty}
\usepackage[small]{caption}

% Check if shell commands can be executed
\ifnum\pdfshellescape=1
% Yes, enabled
\newcommand{\VERSION}{\splice{echo `git log -1 --date=short --format=\%cd`, `git describe --dirty`}}
\else
% No, disabled
\providecommand\VERSION{\today}
\fi
\date{\VERSION}

% Format sections and page heading
\allsectionsfont{\normalsize\RaggedRight}
\pagestyle{fancy}
\renewcommand{\sectionmark}[1]{\markboth{}{\footnotesize{\thesection. #1}}}
\renewcommand{\subsectionmark}[1]{\markboth{}{\footnotesize{\thesubsection. #1}}}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\fancyhead[LE,LO]{\textit{\footnotesize{\nouppercase{\rightmark}}}}
\rhead{\footnotesize{\textit{\VERSION}}}

% Minor formatting settings
\frenchspacing
