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
   
% Cette fonction prend une partition en entree et retourne une flat partition.

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
	    end

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
   
%Cette fonction additione les echantillons des musiques de la liste Musicwithintensifies apres les avoir multiplier par leur facteur.

   fun {Merge Musicwithintensifies}
      %for all -> factor * Mix2
      %addition toute les listes.
      case Musicwithintensifies
      of H|T then
	 case H
	 of Facteur#Music then
	    Facteur * {Mix2 Music}|{Merge T}
	 end
      end
   end
   
%Cette fonction repete une musique un nombre Amount de fois

   fun {Repeat Amount Samples}
      for X in 1..Amount do
	 {List.append Samples Samples}
      end
   end
   
%Cette fonction boucle une musique pendant Duration secondes

   fun {Loop Duration Samples}
      local X Y Z
      in
	 X = {List.length Samples}
	 Y = Duration * 44100.0
	 Z = {Int.'div' Y X}
	 A = {Int.'mod' Y X}
	 if Z > 0 then
	    for I in 1..Z do
	       Samples = {List.append Samples Samples}
	    end
	 end
	 if A > 0 then
	    Samples = {List.append Samples {List.take A}}
	 end
	 Samples
      end
   end
   
%Cette fonction contraint les echantillons a une valeur plancher et plafond

   fun {Clip Low High Samples}
      local X
      in
	 X = {List.length Samples}
	 for I in 1..X do
	    if Samples.I < Low then
	       Samples.I = Low
	    elseif Samples.I > High then
	       Samples.I = High
	    end
	 end
	 Samples
      end
   end

%Cette fonction introduit un echo avec un delais de Delay de secondes et intensifier par un nombre decay.

   fun {Echo Delay Decay Samples}
      local Silence X
      in
	 X = Delay*44100
	 for I in 1..X do
	    Silence = {List.append Silence 0}
	 end
	 Silence = {List.append Silence Samples}
	 {Merge 1.0#Samples|Decay#Silence}
   end

%Cette fonction creer un fondu au debut et a la fin d'une musique d'une duree respective de start et finish secondes
   fun{Fade Start Out Samples}

   end

%Cette fonction recupere la partie de la musique qui se trouve entre Start et Finish secondes, si cette intervalle est plus grand que la musique, celle ci est completer par du silence
   fun {Cut Start Finish Samples}

   end
   
%Cette fonction calcule la liste d'echantillons d'une flat partition.

%formule pour convertir un temps en nombre d'echantillon : temps en sec multiplier par 44100
   fun {Echantillon FlatPartition}
      local Hauteur F D A Samples
      in
	 for X in FlatPartition do
	    case X
	    of H|T then
	       case H
	       of silence(duration:Duration) then
	       [] note(name:Name octave:Octave sharp:Sharp duration:Durationcinstrument:Instrument) then
		  if H.name == c then
		     if H.sharp == false then
			Hauteur = ~9.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     else
			Hauteur = ~8.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     end
		  elseif H.name == d then
		     if H.sharp ==false then
			Hauteur = ~7.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     else
			Hauteur = ~6.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     end
		  elseif H.name == e then
		     Hauteur = ~5.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
		     D = H.duration * 44100.0
		     for Y in 1..d do
			A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			Samples = {List.append Samples A}
		     end
		  elseif H.name == f then
		     if H.sharp == false then
			Hauteur = ~4.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     else
			Hauteur = ~3.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     end
		  elseif H.name == g then
		     if H.sharp == false then
			Hauteur = ~2.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     else
			Hauteur = ~1.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     end
		  elseif H.name == a then
		     if H.sharp == false then
			Hauteur = 0.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     else
			Hauteur = 1.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
			F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
			D = H.duration * 44100.0
			for Y in 1..d do
			   A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			   Samples = {List.append Samples A}
			end
		     end
		  elseif H.name == b then
		     Hauteur = 2.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' h 12.0)} * 440.0
		     D = H.duration * 44100.0
		     for Y in 1..d do
			A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Y) 44100})}
			Samples = {List.append Samples A}
		     end
		  end
	       end
	    end
	 end
	 Samples
      end
   end
   
%Cette fonction prend une musique en entree et retourne une liste d'echantillon.(Mix2 est le pour permettre la recursion)

   fun {Mix P2T Music}
      {Mix2 P2T Music}
   end

%idem  

   fun {Mix2 P2T Music}
      %h = difference par rapport a A4, f = 2**(h div 12)* 440 HZ, ai = 0.5*sin(2pi*f*i/44100)
      case Music
      of samples(Sample) then
	 samples.1

      [] partition(Partition) then
	 {Echantillon {P2T partition.1}}

      [] wave(Filename) then
	 {Project.load wave.1}
	 
      [] merge(Musicwithintensifies) then
	 {Merge Musicwithintensifies}

      [] reverse(Music) then
	 %{list.inverse {Mix2 reverse.1}}

      [] repeat(amount:Amount Music) then
	 {Repeat {Mix2 Music}}

      [] loop(duration:Duration Music) then
	 {Loop loop.duration {Mix2 loop.1}}
	 %calcule la duree totale sur base du nombre de ai
	 %{loop.duration div duree total} -> nombre de son total
	 %loop.duration modulo duree total -> convertion en nombre de ai
      [] clip(low:Sample high:Sample Music) then
	 {Clip clip.low clip.high {Mix2 clip.1}}

      [] echo(delay:Duration decay:Factor Music) then
	 %egale merge avec clone precede d'un silence de delay seconde(ai de silence = 0)
	 {Echo echo.delay echo.decay {Mix2 echo.1}}

      [] fade(start:Duration out:Duration Music) then
	 {Fade fade.start fade.out {Mix2 fade.1}}

      [] cut(start:Duration finish:Duration Music) then
	 {Cut cut.start cut.finish {Mix2 Music}}
	     
	 
	 
    %  {Project.readFile 'wave\animals\cow.wav'}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
   %Start
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


