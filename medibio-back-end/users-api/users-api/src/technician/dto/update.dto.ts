import { Prop } from '@nestjs/mongoose';
import { IsString, IsOptional, IsEmail, IsArray, IsNotEmpty } from 'class-validator';

export class UpdateTechnicianDto {
  
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  password?: string;

  @IsOptional()
  @Prop()
  age: number;


  @IsOptional()
  @IsString()
  speciality?: string;

  @IsOptional()
  @IsString()
  profil?: string;

  @IsNotEmpty()
  @IsArray()
  @IsString({ each: true })
  fcmlist?: string[];
}
