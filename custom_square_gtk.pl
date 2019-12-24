#!/usr/bin/perl -w
use strict;
use Gtk2 '-init';

# Variables convenables pour vrai et faux
use constant TRUE  => 1;
use constant FALSE => 0;

my %files = (); # Function => filename

# Création d'une fenêtre
my $window = Gtk2::Window->new('toplevel');
$window->set_border_width(15);
$window->set_position('center');
# On déclare le titre de la fenêtre
$window->set_title('Blackvoxel cubes');

# On relie l'événement delete event à une fonction de rappel à qui on
# passe comme argument une chaîne de caractère
#$window->signal_connect( 'delete event', \&CloseWindow, "Puisqu'il faut partir..." );

# Le signal "destroy" sera émis parce que la fonction de rappel "CloseWindow"
# renvoie FALSE.
$window->signal_connect( 'destroy', \&DestroyWindow );

# Création d'une boîte dans laquelle on placera les boutons. Nous verrons
# en détail les comportements des boîtes dans le chapître sur les conteneurs.
# Une boîte n'est pas visible. Elle est juste utile pour ranger les widgets
# qu'elle contient.
my $box = Gtk2::VBox->new( FALSE, 10 );

# On place la boîte dans la fenêtre.
$window->add($box);

my %label_for_faces = ();
my $previous        = ''; 
my $table = Gtk2::Table->new(4 , 3 , FALSE );
$table->set_col_spacings(5);
my $line = 0 ;
foreach (qw(faces sommet dessous inventaire)) {
   my $label1 = Gtk2::Label->new("! Empty !");
   my $button1= Gtk2::Button->new("Changer $_");
   my $button_copy= Gtk2::Button->new("Comme $previous");

   $table->attach($label1,0,1,$line,$line+1,'fill','fill',0,0) ;
   $label1->show;
   $label_for_faces{$_}=$label1;

   $button1->signal_connect( 'clicked', \&SelectFile, "$_" );
   $table->attach_defaults($button1,1,2,$line,$line+1 ) ;
   $button1->show;
   
   if ($previous) {
   $button_copy->signal_connect('clicked' , \&FileCopy, [ "$_" , $previous ]);
   $table->attach_defaults( $button_copy,2 ,3 , $line , $line+1 ) ;
   $button_copy->show;
   }

   $line++;
   $previous=$_;
};
$box->pack_start( $table , TRUE , TRUE , 0 );
$table->show;


#foreach (qw(faces sommet dessous inventaire)) {
#  # creation de la box h
#  my $box2 =  Gtk2::HBox->new( FALSE, 0 );
#  my $label1 = Gtk2::Label->new("!");
#  my $button1= Gtk2::Button->new("Changer $_");
#  my $button_copy= Gtk2::Button->new("Comme $previous");
#  $button1->signal_connect( 'clicked', \&SelectFile, "$_" );
#  $button_copy->signal_connect('clicked' , \&FileCopy, [ "$_" , $previous ]);
#  $box2->pack_start( $label1      , TRUE, TRUE, 0) ;
#  $box2->pack_start( $button1     , TRUE, TRUE, 0) ;
#  $box2->pack_start( $button_copy , TRUE , TRUE , 0);
#  $box->pack_start( $box2 , TRUE, TRUE , 0);
#  $label1->show();
#  $button1->show();
#  $button_copy->show() if $previous;
#  $box2->show;
#  $label_for_faces{$_}=$label1;
#  $previous = $_;
#};

my $box2 =  Gtk2::HBox->new( FALSE, 5 );

# Création d'un bouton qui s'appellera 'bouton 1'
my $button1 = Gtk2::Button->new("Faire");

# On relie le signal "clicked" à la fonction de rappel "rappel"
# à qui on passe comme argument la chaîne de caractère "bouton 1".
$button1->signal_connect( 'clicked', \&DoImage );

# On place le bouton 1 dans notre boîte
$box2->pack_start($button1, TRUE, TRUE, 0 );
$box->pack_start( $box2, TRUE, TRUE, 0 );

# On montre le bouton
$button1->show;
$box2->show;

# On refait la même chose pour placer un second bouton dans la boîte
my $button2 = Gtk2::Button->new("Abandonner");
$button2->signal_connect( 'clicked', \&DestroyWindow );
$box2->pack_start( $button2, TRUE, TRUE, 0 );
$button2->show;

# On montre la boîte
$box->show;

# On montre la fenêtre
$window->show();

# On lance la boucle principale.
Gtk2->main;
### La fonction de rappel qui est appelé quand on a cliqué sur un bouton.
sub DoImage {
	my ( $widget ) = @_;
	MakeImage();
}
### La fonction de rappel appelé par l'événement "delete event".
sub CloseWindow {
	my ( $widget, $event, $message ) = @_;

	# On récupère le nom de l'événement
	my $name = $event->type;
	return FALSE;
}
### La fonction de rappel pour fermer la fenêtre
sub DestroyWindow {
	Gtk2->main_quit;
	return FALSE;
}

sub SelectFile {
	my ( $widget, $pressed_button ) = @_;
	my $file_dialog = Gtk2::FileSelection->new($pressed_button);
	#$file_dialog->signal_connect("destroy" , sub {  }) ;
        $file_dialog->cancel_button->signal_connect("clicked" , sub { $file_dialog->hide() });
        $file_dialog->ok_button->signal_connect("clicked" 
		, sub { return if ! -f $file_dialog->get_filename;
			$files{$pressed_button}=$file_dialog->get_filename();
		        $file_dialog->hide();	
			if ($label_for_faces{$pressed_button}) {
				$label_for_faces{$pressed_button}->set_text($files{$pressed_button});
			};
		});
	$file_dialog->hide_fileop_buttons();
	$file_dialog->show();
}

sub FileCopy {
	my ($widget , $data ) = @_ ; 
	my ( $to , $from ) = @$data ; 
	if ($label_for_faces{$to}) {
            $files{$to} = $files{$from} ; 
	    $label_for_faces{$to}->set_text($files{$to});
	};

}

sub MakeImage {
	use Image::Magick ;
        my @images = () ; 
        my %need =( "21" => [ 'faces'  , 180 ] #left
		  , "12" => [ 'faces', 90 ] #front
                  , "22" => [ 'sommet' , 0   ] #top
                  , "32" => [ 'faces'  , 270  ] #back
                  , "42" => [ 'dessous'  , 180 ] #bottom
		  , "23" => [ 'faces'  , 0   ] #right
                  , "44" => [ 'inventaire',0 ] #inventory image
		  );
        my $colone = Image::Magick->new;
	foreach my $line (qw(1 2 3 4)) {
	  my $ligne = Image::Magick->new;
	  foreach my $colm (qw(1 2 3 4)) {
	    if ($need{"$line$colm"}) {
	    	my $image = Image::Magick->new ;
		my $x=$image->Read($files{$need{"$line$colm"}->[0]});
		$image->Resize( width=>128 , height=>128);
		if ($need{"$line$colm"}->[1]) {
		  $image->Rotate($need{"$line$colm"}->[1]);
		};
		push @$ligne , @$image ;
	    } else {
		my $image =  Image::Magick->new;
		$image->Set("128x128");
		$image->ReadImage('canvas:black');
		push @$ligne , @$image ;
	    }
	  }
          my $new = $ligne->Append();
          push @$colone , $new ;
	};
	my $ans = $colone->append( 'stack' => 'false' );
        $ans->display();
  	exit 0;
}
