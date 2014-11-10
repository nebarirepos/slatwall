<!---

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->
<cfimport prefix="swa" taglib="../../../tags" />
<cfimport prefix="hb" taglib="../../../org/Hibachi/HibachiTags" />
<cfparam name="rc.loyaltyAccruement" type="any">
<cfparam name="rc.loyalty" type="any" default="#rc.loyaltyAccruement.getLoyalty()#">
<cfparam name="rc.edit" type="boolean">

<cfoutput>
	<hb:HibachiEntityDetailForm object="#rc.loyaltyAccruement#" edit="#rc.edit#"  
								saveActionQueryString="loyaltyID=#rc.loyalty.getLoyaltyID()#">
								
		<hb:HibachiEntityActionBar type="detail" object="#rc.loyaltyAccruement#" edit="#rc.edit#"
								   backAction="admin:entity.detailloyalty"
								   backQueryString="loyaltyID=#rc.loyalty.getLoyaltyID()#"
								   cancelAction="admin:entity.detailloyalty"
								   cancelQueryString="loyaltyID=#rc.loyalty.getLoyaltyID()#" 
							  	   deleteQueryString="redirectAction=admin:entity.detailloyalty&loyaltyID=#rc.loyalty.getLoyaltyID()#" />
		
		<input type="hidden" name="loyalty.loyaltyID" value="#rc.loyalty.getLoyaltyID()#" />
		
		<hb:HibachiPropertyRow>
			<hb:HibachiPropertyList>
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="activeFlag" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="startDateTime" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="endDateTime" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="expirationTerm" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="accruementType" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="pointType" edit="#rc.edit#">
				<hb:HibachiPropertyDisplay object="#rc.loyaltyAccruement#" property="pointQuantity" edit="#rc.edit#">				
			</hb:HibachiPropertyList>
		</hb:HibachiPropertyRow>
		
		<cfif not listFindNoCase("orderClosed,enrollment", rc.loyaltyAccruement.getAccruementType())>
			<hb:HibachiTabGroup object="#rc.loyaltyAccruement#">
				<hb:HibachiTab view="admin:entity/loyaltyAccruementtabs/producttypes" />
				<hb:HibachiTab view="admin:entity/loyaltyAccruementtabs/products" />
				<hb:HibachiTab view="admin:entity/loyaltyAccruementtabs/skus" />
				<hb:HibachiTab view="admin:entity/loyaltyAccruementtabs/brands" />
			</hb:HibachiTabGroup>
		</cfif>
	</hb:HibachiEntityDetailForm>
</cfoutput>