import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({
  timestamps: true,
})
export class Technician extends Document {

  @Prop()
  name: string;

  @Prop()
  realname: string;

  @Prop({ unique: [true, 'Duplicate email entered'] })
  email: string;

  @Prop()
  password: string;

  @Prop()
  age: number;

  @Prop()
  speciality: string;

  @Prop()
  profil : string;

  @Prop({ required: false, type: [String] })
  fcmlist: string[]; 

}

export const TechnicianSchema = SchemaFactory.createForClass(Technician);
