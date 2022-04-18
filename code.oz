local
   %Auteur : Thomas Lamby     NOMA: 27312000        
   % See project statement for API details.
   %[Project] = {Link ['Project2022.ozf']}
   %Time = {Link ['x-oz:\\boot\Time']}.1.getReferenceTime


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] silence then
	 silence(duration:1.0)
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then
	    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	 [] [N O] then
	    note(name:{StringToAtom [N]}
		 octave:{StringToInt [O]}
		 sharp:false
		 duration:1.0
		 instrument: none)
	 end
      end
   end

   % Cette fonction fixe la duree de la partition au nombre de secondes indique.
   fun {Duration Seconds Partition T}
      local Sum Factor
	 Sum =
	 fun {$ Partition N}
	    case Partition
	    of nil then
	       N
	    [] H|T then
	       case H
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  {Sum T N+H.duration}
	       [] silence(duration:Duration) then
		  {Sum T N+H.duration}
	       [] H2|T2 then
		  {Sum T N+H2.duration}
	       end
	    end
	 end
      in
	 Factor = {Float.'/' Seconds {Sum Partition 0.0}}
	 {Stretch Factor Partition T}
      end
   end
   
   % Cette fonction etire la duree de la partition par le facteur indique
   fun {Stretch Factor Partition V}
      local X in
	 case Partition
	 of nil then
	    {PartitionToTimedList V}
	 [] H|T then
	    case H
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
	       X|{Stretch Factor T V}
	    [] silence(duration:Duration) then
	       X = silence(duration:H.duration*Factor)
	       X|{Stretch Factor T V}
	    [] H2|T2 then
	       case H2
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
		  X|{Stretch Factor T2 nil}|{Stretch Factor T V}
	       [] silence(duration:Duration) then %peut etre pas necessaire en pratique mais grammaire
		  X = silence(duration:H.duration*Factor)
		  X|{Stretch Factor T2 nil}|{Stretch Factor T V}
	       end
	    end
	 end
      end
   end
   
   % Cette fonction repete une partition comprenant la note Note un nombre Amount de fois
   fun {Drone Note Amount Partition}
      if Amount == 0 then
	 {PartitionToTimedList Partition}
      else
	 Note|{Drone Note Amount-1 Partition}
      end
   end    

	 
%Cette fonction transpose la partition d'un certain nombre de demi-tons vers le haut (entier positif) ou vers le bas (entier negatif) ainsi que l'octave si necessaire.
   ListNote = record(c c#s d d#s e f f#s g g#s a a#s b)
   ReverseListNote = record(b a#s a g#s g f#s f e d#s d c#s c)
   fun {Transpose Partition Nsemitones Noctave V}
      local X Y Z
      in
	 case Partition
	 of nil then
	    {PartitionToTimedList V}
	 [] H|T then
	    if H.name == c then
	       if H.sharp == false then
		  Y = 1 + Nsemitones
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  Y = 2 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == d then
	       if H.sharp == false then
		  Y = 3 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
          		case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 4 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
         			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == e then
	       Y = 5 + Nsemitones
	       if Nsemitones < 0 then
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
           			else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.(Y)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  if Y > 12 then
		     Z = Y + (~12)
		     case ListNote.Z
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       end
	    elseif H.name == f then
	       if H.sharp == false then
		  Y = 6 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 7 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == g then
	       if H.sharp == false then
		  Y = 8 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 9 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == a then
	       if H.sharp == false then
		  Y = 10 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 11 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == b then
	       Y = 12 + Nsemitones
	       if Nsemitones < 0 then
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.(Y)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  if Y > 12 then
		     Z = Y + (~12)
		     case ListNote.Z
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       end
	    end
	 end
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      case Partition
      of nil then
	 nil
      [] H|T then
	 case H
	 of Name#Octave then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] duration(seconds:Duration Partition) then
	    if {Int.is H.seconds} then
           {Duration {Int.toFloat H.seconds} {PartitionToTimedList H.1} T}
        else
           {Duration H.seconds {PartitionToTimedList H.1} T}
        end
	    {Duration H.seconds {PartitionToTimedList H.1} T}

	 [] stretch(factor:Factor Partition) then
	    if {Int.is H.factor} then
	       {Stretch {Int.toFloat H.factor} {PartitionToTimedList H.1} T}
	    else
	       {Stretch H.factor {PartitionToTimedList H.1} T}
	    end
	    
	 [] drone(note:Note amount:Amount) then
	    if {Int.is Amount} then
	       {Drone {PartitionToTimedList H.note} H.amount T}
	    else
	       {Drone {PartitionToTimedList H.note} {Float.toInt H.amount} T}

	 [] transpose(semitones:Semitones Partition) then
	    {Transpose {PartitionToTimedList Partition} {Int.'mod' H.semitones 12} {Int.'div' H.semitones 12} T}

     [] H2|T2 then
     	    case H2

     	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
     	       H|{PartitionToTimedList T}

     	    [] silence(duration:Duration) then %pas sure qu'il y ai besoin en pratique mais grammaire
     	       H|{PartitionToTimedList T}

     	    [] Name#Octave then
     	       {PartitionToTimedList H}|{PartitionToTimedList T}

     	    [] Atom then
     	       {PartitionToTimedList H}|{PartitionToTimedList T}
     	    end
	    
	 [] silence then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    H|{PartitionToTimedList T}

	 [] silence(duration:Duration) then
	    H|{PartitionToTimedList T}

     [] Atom then
        {NoteToExtended H}|{PartitionToTimedList T}
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %fun {Mix P2T Music}
      % TODO
    %  {Project.readFile 'wave\animals\cow.wav'}
   %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
   %Start
   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   %Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   %{ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   %{Browse {IntToFloat {Time}-Start} / 1000.0}
   
end


