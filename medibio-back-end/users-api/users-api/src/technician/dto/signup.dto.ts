import { IsArray, IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { Prop } from '@nestjs/mongoose';
export class SignUpDto {
  
  @Prop({ required: true})
  @IsNotEmpty()
  @IsString()
  name: string;

  @Prop({ required: true})
  @IsNotEmpty()
  @IsString()
  realname: string;

  @Prop({ required: true, unique: true }) 
  @IsNotEmpty()
  @IsEmail({}, { message: 'Please enter correct email' })
  email: string;

  @Prop({ required: true, unique: true }) 
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;


  @Prop({ required: true }) 
  
  age: number;


  @Prop({ required: true }) 
  @IsNotEmpty()
  @IsString()
  speciality: string;

  @Prop({ required: true }) 
  @IsNotEmpty()
  @IsString()
  profil: string;

  @IsNotEmpty()
  @IsArray()
  @IsString({ each: true })
  fcmlist?: string[];
}
