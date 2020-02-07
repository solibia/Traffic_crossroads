/**
* Name: mstp5PAZIMNASolibia
* Author: basile
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model mstp5PAZIMNASolibia

global {
	/** Insert the global definitions, variables and actions here */
	
	shape_file shape_file_arrive <- shape_file('../includes/Arrive.shp');
	shape_file shape_file_depart <- shape_file('../includes/zoneDepartArrive.shp');
	shape_file shape_file_feu <- shape_file('../includes/feu.shp');	
	shape_file shape_file_rue <- shape_file('../includes/rue.shp');	
	
	geometry shape <- envelope(shape_file_rue);
	
	init {
		create pointDestination from: shape_file_arrive;
		create pointDepart from: shape_file_depart;
		create Feux from: shape_file_feu;
		create route from: shape_file_rue;
		
		create MoyensTransports number: 5{
			set location <- any_location_in( one_of(pointDepart));
			set speed <- min_speed + rnd(max_speed - min_speed);
			set depart <- one_of (pointDepart);
			set destination <- one_of (pointDestination);
		}
	}
}

species pointDepart {
	rgb color <- #white;
	
	aspect basic {
		draw shape color: color;
	}
}

species pointDestination {
	rgb color <- #white;
	aspect basic {
		draw shape color: color;
	}
}

species route {
	rgb color <- #blue;
	aspect basic {
		draw shape color: color;
	}
}

species Feux{
	int counter <- 0;
	rgb current_color <- #red;
	int red_duration <- 20;
	int green_duration <- 30;
	//color couleur <- rnd_color(255);
	
	reflex fonction {
		counter <- counter +1;
		if((current_color = #red) and (counter >= red_duration)){
			//changer la couleur
			current_color <- #green;
			//reinitialiser le compteur
			counter <- 0;
		}else if((current_color = #green) and (counter >= green_duration)){
			//changer la couleur
			current_color <- #green;
			//reinitialiser le compteur
			counter <- 0;		
		}
	}
	
	aspect basic {
		draw circle(rnd(5)) color:rnd_color(255);
	}
}

species MoyensTransports skills:[moving]{	
	int size <- rnd(2) + 1;	
	float min_speed <- 2.0;
	float max_speed <- 6.0;
	int time_to_appear <- 60;
	Feux feux;
	pointDepart depart;
	pointDestination arrive;

	reflex init {
		//Détecter zone de départ
		set depart <- one_of (pointDepart);
		set arrive <- one_of (pointDestination);		
		//Détecter zone d'arrivée
	}
	
	reflex deplacement{
		do goto target: arrive speed:speed;
		ask feux {
			float c <- self distance_to myself;				
			if(c<=5 and current_color = #red){
				//s'arreter
				myself.speed<-0;
			}
		}
	}
	
	reflex quitterFeux when: speed=0{
		ask feux {
			float c <- self distance_to myself;				
			if(current_color = #green){
				myself.speed <- rnd(myself.max_speed - myself.min_speed)+ myself.min_speed;
			}
		}		
		do goto target: arrive speed:speed;		
	}
	
	reflex fini when: (self distance_to destination)<1 {
		//Créer un nouveau agent de mm
		create MoyensTransports number: 1{
			set location <- self.depart;
			set speed <- min_speed + rnd(max_speed - min_speed);
			set depart <- one_of (pointDepart);
			set destination <- one_of (pointDestination);
		}		
		do die;
		//le tuer
	}
	
	aspect basic {
		draw circle(size) color:rnd_color(255);
	}
}


experiment mstp5PAZIMNASolibia type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display mstp5PAZIMNASolibia {
			species route aspect: basic;
			species Feux aspect: basic;
			species MoyensTransports aspect: basic;
		}		
	}
}
