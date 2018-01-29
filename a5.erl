-module(a5).
-compile(export_all).
-include ("vtcons.hrl").

%defines the min and max timeout amounts
-define(MIN_TIMEOUT, 1000).
-define(MAX_TIMEOUT, 5000).

%defines the location of the scoreboards topleft corner
-define(SCORE_X_LOC, 1).
-define(SCORE_Y_LOC, 1).

%1 X LOC and 1 Y LOC defines the location of a specific philosopher's top left most corner,
%the rest of the philosopher is computed and drawn from there.
-define(X_1_LOC, 25).
-define(X_2_LOC, 3).
-define(X_3_LOC,40).
-define(Y_1_LOC, 3).
-define(Y_2_LOC,10).
-define(Y_3_LOC,17).

%Borrowed from Fred Barnes a4fred.erl file, University of Kent [ https://moodle.kent.ac.uk/2015/pluginfile.php/258869/mod_resource/content/1/a3fred.erl ]
%maps atoms to their string counterparts
status_str(aristotle)-> "Aristotle";
status_str(descartes)-> "Descartes";
status_str(marx)-> "Marx";
status_str(batman)-> "Batman";
status_str(plato)-> "Plato";
status_str (X) -> atom_to_list (X).

%generates a random seed then uses it to create a random number between Min and Max inclusive
random_number(Min, Max)->
random:seed(erlang:phash2([node()]),					
			erlang:monotonic_time(),					
			erlang:unique_integer()),
T = random:uniform((Max - Min) + 1),
T2 = (T-1) + Min,
T2.

%wait timer [modified from Fred Barnes, University of Kent,[ https://moodle.kent.ac.uk/2015/pluginfile.php/254311/mod_resource/content/1/clock.erl ]
wait(Min, Max) ->										
	TimeSleeping = random_number(Min, Max),
	timer:sleep(TimeSleeping).	

%uses random_number to generate a "random" thought, hungry, or eating message when called
generate_thought()->
	Num = random_number(1, 8),
	case Num of 
		1-> "   What is love?    ";
		2-> "what makes fire hot?";
		3-> "What makes us tick? ";
		4-> " Where is my neck?  ";
		5-> "  Why do I exist?   ";
		6-> "    Who made me?    ";
		7-> "   I like turtles   ";
		8-> "Who's paying my tab?"
	end. 

generate_hungry()->
	Num = random_number(1, 8),
	case Num of 
		1-> "   I'm so hungry    ";
		2-> "  *hunger noises*   ";
		3-> "  *stomach groans*  ";
		4-> " please, so hungry  ";
		5-> " I'm so very hungry ";
		6-> "My tummy is rumbling";
		7-> " *stomache growls*  ";
		8-> "  Please Feed me!   "
	end. 

generate_eating()->
	Num = random_number(1, 8),
	case Num of 
		1-> "MMM SPAG BOL, MY FAV";
		2-> " Om Nom Nom Nom Nom ";
		3-> " *Munch Munch Munch*";
		4-> "   *Scarfs food*    ";
		5-> "*Chomp Chomp Chomp* ";
		6-> "Num num num num num ";
		7-> "Random eating noise ";
		8-> " *Shovels food in*  "
	end.


%All these functions draw different animations of the philosophers and the scoreboard
%Name is the Philosopher's Name String
%X is the Philosopher's topleft most X Location
%Y is the Philosopher's topleft most Y Location
%Msg is the msg string to be printed to screen
%ForkColour is the colour of the fork set using vtcons ansi attribute

%draws philosophers face and thinking message
phil_thinking(Name,X, Y, Msg) ->
	vtcons ({cursor_xy, X+9, Y}),
	vtcons ({string, "@@@@@ ..("++Msg++")"}),
	vtcons ({cursor_xy, X+8, Y+1}),
	vtcons ({string, "@ . . @"}),
	vtcons ({cursor_xy, X+8, Y+2}),
	vtcons ({string, "@  .  @"}),
	vtcons ({cursor_xy, X+8, Y+3}),
	vtcons ({string, "$__-__$"}),
	vtcons ({cursor_xy, X+9, Y+4}),
	vtcons ({string, "''''' "}),
	vtcons ({cursor_xy, X+8, Y+5}),
	vtcons ({string, Name}).

%updates the philosophers msg
phil_msg(X, Y, Msg)->
	vtcons ({cursor_xy, X+18, Y}),
	vtcons ({string, Msg++")"}).

%draws the philosophers left fork and colours it
phil_gotleftfork(X,Y,ForkColour)->
	vtcons ({ansi, ForkColour}),
	vtcons ({cursor_xy, X, Y+2}),
	vtcons ({string, "{_|_}"}),
	vtcons ({cursor_xy, X+2, Y+3}),
	vtcons ({string, "|"}),
	vtcons ({cursor_xy, X+2, Y+4}),
	vtcons ({string, "|"}),
	vtcons ({ansi, 0}).

%draws philosophers right fork and colours it
phil_gotrightfork(X,Y,ForkColour)->
	vtcons ({ansi, ForkColour}),
	vtcons ({cursor_xy, X+18,Y+2}),
	vtcons ({string, "{_|_}"}),
	vtcons ({cursor_xy,  X+20,Y+3}),
	vtcons ({string, "|"}),
	vtcons ({cursor_xy,  X+20,Y+4}),
	vtcons ({string, "|"}),
	vtcons ({ansi, 0}).

%draws the philosophers "eating" mouth
phil_mouth(X,Y)->
	vtcons ({cursor_xy,  X+9,Y+3}),
	vtcons ({string, "__=__$"}).

%clears the forks when they are dropped by philosopher
phil_dropforks(X,Y)->
	vtcons ({cursor_xy,  X, Y+2}),
	vtcons ({string, "     "}),
	vtcons ({cursor_xy,  X+2, Y+3}),
	vtcons ({string, " "}),
	vtcons ({cursor_xy,  X+2, Y+4}),
	vtcons ({string, " "}),
	vtcons ({cursor_xy,  X+18,Y+2}),
	vtcons ({string, "     "}),
	vtcons ({cursor_xy,  X+20,Y+3}),
	vtcons ({string, " "}),
	vtcons ({cursor_xy,  X+20,Y+4}),
	vtcons ({string, " "}).
	
%Updates the scoreboard
%PhilosopherName is the Philosopher's Name string
%NumberOfMealsEaten is the count of eaten meals 
%PhilScoreYLocation is the line on which the Philosophers score is kept
update_scoreboard(PhilosopherName, NumberOfMealsEaten, PhilScoreYLocation)->
	vtcons ({cursor_xy,  ?SCORE_X_LOC, PhilScoreYLocation}),
	vtcons ({ansi, 36}),
	vtcons ({string, PhilosopherName++":"}),
	vtcons ({cursor_xy,  ?SCORE_X_LOC+10, PhilScoreYLocation}),
	vtcons ({num, NumberOfMealsEaten}),
	vtcons ({ansi, 0}).

%simple evaluate function
dothis(F)-> F().

%updates the animation depending on which state the philosopher is in
%PhilosopherName is the String value of the philosopher's name
%State is an atom corresponding to the philosopher's current state, eating, hungry etc.
%X is the Philosopher's topleft most X Location
%Y is the Philosopher's topleft most Y Location
display_update(PhilosopherName, State, X,Y)->
	case State of
		thinking ->	phil_thinking(PhilosopherName,X,Y,	dothis(fun a5:generate_thought/0));
		hungry 	 -> phil_msg(X,Y,dothis(fun a5:generate_hungry/0));
		eating   -> phil_msg(X,Y,dothis(fun a5:generate_eating/0)),
					phil_mouth(X,Y);
		grabForks->	phil_msg(X,Y,"   grabbing forks.. ")
	end.
	
%updates the animation depending on which state the philosopher is in
%State is an atom corresponding to the philosopher's current state, gotLeftFork and gotRightFork.
%X is the Philosopher's topleft most X Location
%Y is the Philosopher's topleft most Y Location
%ForkColour is the forks ansi colour
display_update({State, X, Y, ForkColour}) ->
	case State of 
		gotLeftFork  -> phil_gotleftfork(X, Y, ForkColour);
		gotRightFork ->	phil_gotrightfork(X, Y, ForkColour)
	end.

%called before display() to setup the scoreboard info 
setup_display()->
	vtcons ({cursor_xy,  ?SCORE_X_LOC, ?SCORE_Y_LOC}),
	vtcons ({ansi, 1, 4, 31}),
	vtcons ({string, "Meals Eaten"}),
	vtcons ({ansi, 0}),
	display().
	
%Processes messages from philosophers and forks to create  an animation
display() ->
	receive
		{dropForks, PhilosopherName, Count}->
		case PhilosopherName of
			aristotle ->	
				update_scoreboard(status_str(PhilosopherName), Count, ?SCORE_Y_LOC+1),
				phil_dropforks(?X_1_LOC,?Y_1_LOC);
			descartes ->	
				update_scoreboard(status_str(PhilosopherName), Count, ?SCORE_Y_LOC+2),
				phil_dropforks(?X_2_LOC,?Y_2_LOC);
			marx 	  ->	
				update_scoreboard(status_str(PhilosopherName), Count, ?SCORE_Y_LOC+3),
				phil_dropforks(?X_2_LOC,?Y_3_LOC);
			batman 	  ->	
				update_scoreboard(status_str(PhilosopherName), Count, ?SCORE_Y_LOC+4),
				phil_dropforks(?X_3_LOC,?Y_3_LOC);
			plato 	->	
				update_scoreboard(status_str(PhilosopherName), Count, ?SCORE_Y_LOC+5),
				phil_dropforks(?X_3_LOC,?Y_2_LOC)		
		end;
		{State, PhilosopherName, From} -> 		
		case PhilosopherName of
			aristotle ->	
				display_update(status_str(PhilosopherName), State, ?X_1_LOC, ?Y_1_LOC),
				From ! ack;
			descartes ->	
				display_update(status_str(PhilosopherName), State, ?X_2_LOC, ?Y_2_LOC),
				From ! ack;
			marx 		->	
				display_update(status_str(PhilosopherName), State, ?X_2_LOC, ?Y_3_LOC),
				From ! ack;
			batman 	->	
				display_update(status_str(PhilosopherName), State, ?X_3_LOC, ?Y_3_LOC),
				From ! ack;
			plato 	->	
				display_update(status_str(PhilosopherName), State, ?X_3_LOC, ?Y_2_LOC),
				From ! ack
		end;
		{State, {PhilosopherName, ForkColour}} ->
		case PhilosopherName of 
			aristotle ->	display_update({State, ?X_1_LOC, ?Y_1_LOC, ForkColour});
			descartes ->	display_update({State, ?X_2_LOC, ?Y_2_LOC, ForkColour});
			marx 	  ->	display_update({State, ?X_2_LOC, ?Y_3_LOC, ForkColour});
			batman	  ->	display_update({State, ?X_3_LOC, ?Y_3_LOC, ForkColour});
			plato 	  ->	display_update({State, ?X_3_LOC, ?Y_2_LOC, ForkColour})
		end		
	end,
	display().	

%ForkColour is an int that is used to colour the fork a specific colour using vtcons
%Display is the PID of the display process that fork communicates with
fork(ForkColour, Display) ->
	receive 
		{From, pickUp, leftFork, PickedUpBy} ->
			Display ! {gotLeftFork, {PickedUpBy, ForkColour}},
			From ! {pickedUp, self()};										
		{From, pickUp, rightFork, PickedUpBy} -> 
			Display ! {gotRightFork, {PickedUpBy, ForkColour}},
			From ! {pickedUp, self()}
	end,
	receive
		{Pid, putDown} ->	Pid ! {putDown, self()}
	end,
	fork(ForkColour, Display).

%Name is the atom value which corresponds to a string of a specific philosopher
%LeftFork and RightFork are the forks the philosopher has within reach, left and right 
%Display is the PID of the display process that philosopher communicates with
%Count is the number of times a Philosopher has eaten a meal, starting at 1.
philosopher(Name, LeftFork, RightFork, Display, Count) ->
	Display ! {thinking, Name, self()},
	receive 
		ack -> ack
	end,
	wait(?MIN_TIMEOUT, ?MAX_TIMEOUT),	
		
	Display ! {hungry, Name, self()},	
	receive 
		ack -> ack
	end,
	
	Display ! {grabForks, Name, self()},
	receive 
		ack -> ack
	end,
	LeftFork ! {self(), pickUp,leftFork,Name},
	RightFork ! {self(), pickUp,rightFork,Name},				
	receive															
		{pickedUp, LeftFork} -> donothing;
		{pickedUp, RightFork} -> donothing					
	end,
	receive															
		{pickedUp, LeftFork} -> donothing;
		{pickedUp,RightFork} -> donothing					
	end,
	
	Display ! {eating, Name, self()},	
	receive 
		ack -> ack
	end,	
	wait(?MIN_TIMEOUT, ?MAX_TIMEOUT),							
	LeftFork ! {self(), putDown },					
	RightFork ! {self(), putDown},	
	receive															
		{putDown, LeftFork} -> Display ! {dropForks,Name,Count};
		{putDown, RightFork} -> Display ! {dropForks,Name,Count}					
	end,
	receive															
		{putDown, LeftFork} -> Display ! donothing;
		{putDown, RightFork} -> Display ! donothing		
	end,
	philosopher(Name, LeftFork, RightFork,Display, Count+1).

%Forks are spawned with a vtcons colour value and the pid of Display to send msgs
%Philosophers are spawned with their name atom, PID of their left fork, their right fork and display, 
%the final int being their meals eaten count which starts at 1 as by the time its sent it will be 1 meal eaten
%when college is run it sets the cursor to invisible, clears the screen and then waits indefinitely
%The receive is to have it wait so that it doesn't print "true" to the screen during the animation
college () ->	
	Display = spawn (?MODULE, setup_display, []),
	Fork1 = spawn (?MODULE, fork, [31,Display]),
	Fork2 = spawn (?MODULE, fork, [32,Display]),
	Fork3 = spawn (?MODULE, fork, [33,Display]),
	Fork4 = spawn (?MODULE, fork, [36,Display]),
	Fork5 = spawn (?MODULE, fork, [35,Display]),
	spawn (?MODULE, philosopher, [aristotle, Fork1,Fork2, Display, 1]),
	spawn (?MODULE, philosopher, [descartes, Fork5,Fork1, Display, 1]),
	spawn (?MODULE, philosopher, [marx, Fork4, Fork5, Display, 1]),
	spawn (?MODULE, philosopher, [batman, Fork3, Fork4, Display, 1]),		%I know Batman was not a philosopher! xD
	spawn (?MODULE, philosopher, [plato, Fork2, Fork3, Display, 1]),
	vtcons ({cursor_invisible}),
	vtcons ({erase_screen}),
	receive 
		impossible -> true
	end.
	
	