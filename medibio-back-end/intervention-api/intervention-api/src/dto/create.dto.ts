import { 
  IsNotEmpty, 
  IsString, 
  IsArray, 
  ValidateNested, 
  IsOptional, 
  Length, 
  IsInt
} from "class-validator";
import { Type } from "class-transformer";
/**  @Prop({ required: false })
  id: string;

  @Prop({ required: false })
  parcid: string;

  @Prop({ required: false })
  designation: string;

  @Prop({ required: false })
  us: string;

  @Prop({ required: false })
  quantity: string;

  @Prop({ required: false })
  type: string; */
class ArticleDto {

  
  @IsOptional()
  @IsString()
  id?: string;

  @IsOptional()
  @IsString()
  parcid?: string;

  @IsOptional()
  @IsString()
  designation?: string;

  @IsOptional()
  @IsString()
  us?: string;

  @IsOptional()
  @IsString()
  quantity?: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsString()
  ref?: string;

  @IsOptional()
  @IsString()
  commentaire?: string;
}

class ParcDto {
  
  @IsOptional()
  @IsString()
  addressSite?: string;

  @IsOptional()
  @IsString()
  article?: string;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ArticleDto)
  articles?: ArticleDto[];

  @IsOptional()
  @IsString()
  couvertureParContrat?: string;

  @IsOptional()
  @IsString()
  designation?: string;

  @IsOptional()
  @IsString()
  designationSite?: string;

  @IsOptional()
  @IsString()
  firmware?: string;

  @IsOptional()
  @IsString()
  forced?: string;

  @IsOptional()
  @IsString()
  id?: string;

  @IsOptional()
  isSelected?: boolean;

  @IsOptional()
  @IsString()
  localisation?: string;

  @IsOptional()
  @IsString()
  marque?: string;

  @IsOptional()
  @IsString()
  marque_designation?: string;

  @IsOptional()
  @IsString()
  numserie?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  parcHistoryList?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  report?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  reportDraft?: string[];

  @IsOptional()
  @IsString()
  reportState?: string;

  @IsOptional()
  @IsString()
  software?: string;

  @IsOptional()
  @IsString()
  typeContrat?: string;



  //attitude et apparence - qualité de prestation -communication - globlement ---- problemType


  @IsOptional()
  @IsString()
  attitudeApparence?: string;

  @IsOptional()
  @IsString()
  qualityprestation?: string;

  @IsOptional()
  @IsString()
  communication ?: string;

  @IsOptional()
  @IsString()
  globlement?: string;

  @IsOptional()
  @IsString()
  problemType?: string;

  @IsOptional()
  problemTypeList?: string[];


  @IsOptional()
  @IsString()
  intitule?: string;

  @IsOptional()
  @IsString()
  codeRapport?: string;


  @IsOptional()
  interventions?: string[];

  @IsOptional()
  datesInterventions?: string[];


  @IsOptional()
  techniciens?: string[];


  @IsOptional()
  commentaires?: string[];

  @IsOptional()
  observation?: string;


}

export class CreateDto {

  @IsOptional()
  @IsString()
  BL?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  BL_Article?: string[];

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  articleMissionExpense?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  fcmlisttokens?: string[];

  @IsOptional()
  @IsString()
  calendardate?: string;

  @IsOptional()
  @IsString()
  client?: string;

  @IsOptional()
  @IsString()
  codeaddress?: string;

  @IsOptional()
  @IsString()
  couvertureglobale?: string;

  @IsOptional()
  @IsString()
  date?: string;

  @IsOptional()
  @IsString()
  debuteHour?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  duration?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  enddate?: string;

  @IsOptional()
  @IsString()
  finishHour?: string;

  @IsNotEmpty()
  @IsString()
  id?: string;

  @IsNotEmpty()
  @IsString()
  _id?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  idParcArray?: string[];

  @IsOptional()
  @IsString()
  id_client?: string;

  @IsOptional()
  @IsString()
  interventionId?: string;

  @IsOptional()
  isPlanified?: boolean;

  @IsOptional()
  isSaved?: boolean;

  @IsOptional()
  @IsString()
  lieu?: string;

  @IsOptional()
  @IsString()
  locationLatitude?: string;

  @IsOptional()
  @IsString()
  locationLongitude?: string;

  @IsOptional()
  @IsString()
  mobilestatus?: string;

  @IsOptional()
  @IsString()
  npid?: string;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ParcDto)
  parcs?: ParcDto[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pausedChronoDataArray?: string[];

  @IsOptional()
  @IsString()
  realdepartureDate?: string;

  @IsOptional()
  @IsString()
  realdepartureTime?: string;

  @IsOptional()
  @IsString()
  realduration?: string;

  @IsOptional()
  @IsString()
  realenddate?: string;

  @IsOptional()
  @IsString()
  realendtime?: string;

  @IsOptional()
  @IsString()
  realstartdate?: string;

  @IsOptional()
  @IsString()
  realstarttime?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  ressources?: string[];

  

  @IsOptional()
  @IsString()
  satisfaction?: string;

  @IsOptional()
  @IsString()
  state?: string;

  @IsOptional()
  @IsString()
  technicienRealName?: string;

  @IsOptional()
  @IsString()
  technicienname?: string;

  @IsOptional()
  @IsString()
  tel?: string;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsString()
  urgency?: string;

  @IsOptional()
  @IsString()
  user?: string;


  @IsOptional()
  @IsString()
  attitudeApparenceItv?: string;

  @IsOptional()
  @IsString()
  qualityprestationItv?: string;

  @IsOptional()
  @IsString()
  communicationItv?: string;

  @IsOptional()
  @IsString()
  globlementItv?: string;


  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  realstarttimelist?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  realendtimelist?: string[];


  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  realstartdaylist?: string[];




}


//MED2406INT00000088
