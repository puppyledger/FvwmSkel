package Pdt::Ascii;

# #
my $VERSION = '2018-04-13.07-03-22.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: asdf

sub doinit { # workaround. We cannot call output() from _init. Its a bug.
   my $self       = shift;
   my $definition = shift;

   # warn length($definition) ;

   my $bynametable = $self->asciibyname($definition);
   my $bynumtable  = $self->asciibynum();

   return ( $bynametable, $bynumtable );
}

sub byname { # lookup a number by name
   my $self = shift;
   my $name = shift;
   return $self->{'asciibyname'}->{$name};
}

sub bynum { # lookup a name by a number
   my $self = shift;
   my $num  = shift;
   return $self->{'asciibynum'}->{$num};
}

sub chrisplaintext { # detect user space characters  (probably faster than regex)
   my $self = shift;
   return ( $self->ordisplaintext( ord( $_[ 0 ] ) ) );
}

sub ordisplaintext { # detect user space characters by number (probably fastyer than regex)
   my $self = shift;
   return 1 if ( $_[ 0 ] > 31 && $_[ 0 ] < 127 );
   return 0;
}

sub asciibynum { # configure a number to name table
   my $self = shift;

   my $byname = $self->{'asciibyname'};
   my $bynum  = {};

   foreach my $k ( keys %$byname ) {
      unless ( exists $bynum->{ $byname->{$k} } ) {    # ignore duplicates
         $bynum->{ $byname->{$k} } = $k;
      }
   }

   $self->{'asciibynum'} = $bynum;

   # warn scalar( keys( %{ $self->{'asciibyname'} } ) );
   # warn scalar( keys( %{ $self->{'asciibynum'} } ) );

   return $self;
}

sub asciibyname { # configure a name to number table
   my $self = shift;

   # warn "BYNAME" ;

   my $definition = shift;    # this is the output() text

   my @ascii = split( /\n/, $definition );

   my $table = {};

   my $n = 0;                 # name count

   foreach (@ascii) {
      chomp $_;

      my @foo = split( /\s+/, $_ );
      my @dah = split( /\,/,  $foo[ 1 ] );

      foreach my $k (@dah) {
         $table->{$k} = $foo[ 0 ];
         $n++;
      }
   }

   $self->{'asciibyname'} = $table;

   return ($table);
}

__DATA__
0  NULL
1  SOH
2  STX
3  ETX
4  EOT
5  ENQ
6  ACK
7  BEL
8  BS
9  HT,TAB
10 LF
11 VT
12 FF
13 CR
14 SO
15 SI
16 DLE
17 DC1
18 DC2
19 DC3
20 DC4
21 NAK
22 SYN
23 ETB
24 CAN
25 EM
26 SUB
27 ESC
28 FS
29 GS
30 RS
31 US
32 SPACE
33 \!
34 "
35 #
36 $
37 %
38 &
39 \'
40 (
41 )
42 *
43 +
44 ,
45 -
46 .
47 /
48 0
49 1
50 2
51 3
52 4
53 5
54 6
55 7
56 8
57 9
58 :
59 ;
60 <
61 =
62 >
63 ?
64 @
65 A
66 B
67 C
68 D
69 E
70 F
71 G
72 H
73 I
74 J
75 K
76 L
77 M
78 N
79 O
80 P
81 Q
82 R
83 S
84 T
85 U
86 V
87 W
88 X
89 Y
90 Z
91 [
92 \\
93 ]
94 ^
95 _
96 `
97 a
98 b
99 c
100   d
101   e
102   f
103   g
104   h
105   i
106   j
107   k
108   l
109   m
110   n
111   o
112   p
113   q
114   r
115   s
116   t
117   u
118   v
119   w
120   x
121   y
122   z
123   {
124   |
125   }
126   ~
127   DEL
128   Ç
129   ü
130   é
131   â
132   ä
133   à
134   å
135   ç
136   ê
137   ë
138   è
139   ï
140   î
141   ì
142   Ä
143   Å
144   É
145   æ
146   Æ
147   ô
148   ö
149   ò
150   û
151   ù
152   ÿ
153   Ö
154   Ü
155   ø
156   £
157   Ø
158   ×
159   ƒ
160   á
161   í
162   ó
163   ú
164   ñ
165   Ñ
166   ª
167   º
168   ¿
169   ®
170   ¬
171   ½
172   ¼
173   ¡
174   «
175   »
176   ░
177   ▒
178   ▓
179   │
180   ┤
181   Á
182   Â
183   À
184   ©
185   ╣
186   ║
187   ╗
188   ╝
189   ¢
190   ¥
191   ┐
192   └
193   ┴
194   ┬
195   ├
196   ─
197   ┼
198   ã
199   Ã
200   ╚
201   ╔
202   ╩
203   ╦
204   ╠
205   ═
206   ╬
207   ¤
208   ð
209   Ð
210   Ê
211   Ë
212   È
213   ı
214   Í
215   Î
216   Ï
217   ┘
218   ┌
219   █
220   ▄
221   ¦
222   Ì
223   ▀
224   Ó
225   ß
226   Ô
227   Ò
228   õ
229   Õ
230   µ
231   þ
232   Þ
233   Ú
234   Û
235   Ù
236   ý
237   Ý
238   ¯
239   ´
240   ¬
241   ±
242   ‗
243   ¾
244   ¶
245   §
246   ÷
247   ¸
248   °
249   ¨
250   •
251   ¹
252   ³
253   ²
254   ■
255   nbsp
2797 alt-a
2798 alt-b
2799 alt-c
27100 alt-d
27101 alt-e
27102 alt-f
27103 alt-g
27104 alt-h
27105 alt-i
27106 alt-j
27107 alt-k
27108 alt-l
27109 alt-m
27110 alt-n
27111 alt-o
27112 alt-p
27113 alt-q
27114 alt-r
27115 alt-s
27116 alt-t
27117 alt-u
27118 alt-v
27119 alt-w
27120 alt-x
27121 alt-y
27122 alt-z
